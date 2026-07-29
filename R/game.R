# Game state ------------------------------------------------------------------

#' Construct a game state
#'
#' Low-level constructor for the `dp_game` S3 class: trusted input, no
#' validation. Use [dp_new_game()] instead.
#'
#' @param map A [dp_map] object.
#' @param units A tibble of units with columns `power`, `type`, `loc`.
#' @param sc_owner Named character vector mapping supply centre to owner.
#' @param season `"Spring"`, `"Fall"` or `"Winter"`.
#' @param year Integer year.
#' @param phase `"movement"`, `"retreat"` or `"build"`.
#' @param powers Character vector of powers in the game.
#' @param dislodged A tibble of dislodged units awaiting retreat.
#' @param status A list of status flags, such as the winner.
#' @return An object of class `dp_game`.
#' @noRd
new_dp_game <- function(map, units, sc_owner, season, year, phase, powers,
                        dislodged = .empty_dislodged(), status = list()) {
  stopifnot(inherits(map, "dp_map"))
  structure(
    list(
      map = map,
      units = units,
      sc_owner = sc_owner,
      season = season,
      year = as.integer(year),
      phase = phase,
      powers = powers,
      dislodged = dislodged,
      status = status
    ),
    class = "dp_game"
  )
}

#' Validate a game state
#'
#' Checks the invariants of a `dp_game`: at most one unit per province, every
#' unit on a legal location for its type, supply-centre ownership restricted to
#' real centres and real powers, and a recognised season/phase pair.
#'
#' @param x A candidate `dp_game`.
#' @param call Caller environment, for error reporting.
#' @return `x`, invisibly validated.
#' @noRd
validate_dp_game <- function(x, call = rlang::caller_env()) {
  .check_class(x, "dp_game", call = call)
  prov <- .province(x$units$loc)
  if (anyDuplicated(prov)) {
    dup <- unique(prov[duplicated(prov)])
    cli::cli_abort(
      "More than one unit occupies {.val {dup}}.",
      call = call
    )
  }
  if (!all(x$units$type %in% c("army", "fleet"))) {
    cli::cli_abort("Units must be armies or fleets.", call = call)
  }
  bad <- setdiff(names(x$sc_owner), x$map$supply_centres)
  if (length(bad) > 0L) {
    cli::cli_abort(
      "{.val {bad}} {?is/are} not {?a supply centre/supply centres}.",
      call = call
    )
  }
  if (!x$season %in% c("Spring", "Fall", "Winter")) {
    cli::cli_abort("Unknown season {.val {x$season}}.", call = call)
  }
  if (!x$phase %in% c("movement", "retreat", "build")) {
    cli::cli_abort("Unknown phase {.val {x$phase}}.", call = call)
  }
  invisible(x)
}

#' Start a new standard Diplomacy game
#'
#' Initialises a game in the Spring 1901 movement phase with the canonical
#' opening position: 22 units across the seven Great Powers, each power owning
#' its home supply centres.
#'
#' @param map A [dp_map] object. Defaults to the standard board.
#' @param year Starting year. Default `1901`.
#' @param call Caller environment, for error reporting. Experts only.
#' @return A [dp_game] object in the Spring movement phase.
#' @export
#' @family setup
#' @examples
#' g <- dp_new_game()
#' g
#' nrow(g$units)
dp_new_game <- function(map = dp_map(), year = 1901,
                        call = rlang::caller_env()) {
  .check_class(map, "dp_map", call = call)
  year <- .check_count(year, min = 1L, call = call)
  hc <- dp_home_centres(map)
  sc_owner <- stats::setNames(hc$power, hc$centre)
  validate_dp_game(
    new_dp_game(
      map = map,
      units = map$start_units,
      sc_owner = sc_owner,
      season = "Spring",
      year = year,
      phase = "movement",
      powers = map$powers,
      dislodged = .empty_dislodged(),
      status = list(winner = NA_character_, over = FALSE, outcome = NA_character_)
    ),
    call = call
  )
}

#' Build a game state from an explicit position
#'
#' Convenience constructor used by the test suites and by the Shiny board
#' editor: places the given units on the board and fills supply-centre
#' ownership from the home centres unless `sc_owner` says otherwise.
#'
#' @param units A tibble or data frame with columns `power`, `type`, `loc`.
#' @param map A [dp_map] object.
#' @param season `"Spring"`, `"Fall"` or `"Winter"`.
#' @param year Integer year.
#' @param phase `"movement"`, `"retreat"` or `"build"`.
#' @param sc_owner Optional named character vector mapping supply centre to
#'   owning power. Defaults to home ownership.
#' @param dislodged Optional tibble of dislodged units awaiting retreat, with
#'   columns `power`, `type`, `loc` and `from`.
#' @param call Caller environment, for error reporting. Experts only.
#' @return A validated [dp_game] object.
#' @export
#' @family setup
#' @examples
#' pos <- data.frame(
#'   power = c("France", "Germany"),
#'   type = c("army", "army"),
#'   loc = c("par", "mun")
#' )
#' dp_game_from_units(pos)
dp_game_from_units <- function(units, map = dp_map(), season = "Spring",
                               year = 1901, phase = "movement",
                               sc_owner = NULL, dislodged = NULL,
                               call = rlang::caller_env()) {
  .check_class(map, "dp_map", call = call)
  season <- rlang::arg_match(season, c("Spring", "Fall", "Winter"),
                             error_call = call)
  phase <- rlang::arg_match(phase, c("movement", "retreat", "build"),
                            error_call = call)
  year <- .check_count(year, min = 1L, call = call)
  units <- tibble::as_tibble(units)
  if (nrow(units) > 0L) {
    need <- c("power", "type", "loc")
    miss <- setdiff(need, names(units))
    if (length(miss) > 0L) {
      cli::cli_abort("{.arg units} is missing column{?s} {.val {miss}}.",
                     call = call)
    }
    units$power <- .match_power(units$power, map$powers, call = call)
    units$loc <- vapply(
      seq_len(nrow(units)),
      function(i) .normalise_loc(map, tolower(units$loc[i]), units$type[i],
                                 call = call),
      character(1)
    )
    units <- units[, c("power", "type", "loc")]
  } else {
    units <- .empty_units()
  }

  if (is.null(sc_owner)) {
    hc <- dp_home_centres(map)
    sc_owner <- stats::setNames(hc$power, hc$centre)
  }
  if (is.null(dislodged)) dislodged <- .empty_dislodged()

  validate_dp_game(
    new_dp_game(
      map = map, units = units, sc_owner = sc_owner, season = season,
      year = year, phase = phase, powers = map$powers,
      dislodged = tibble::as_tibble(dislodged),
      status = list(winner = NA_character_, over = FALSE,
                    outcome = NA_character_)
    ),
    call = call
  )
}

#' Test whether an object is a game
#'
#' @param x An object to test.
#' @return A logical scalar.
#' @export
#' @family setup
#' @examples
#' is_dp_game(dp_new_game())
is_dp_game <- function(x) inherits(x, "dp_game")

#' Units currently on the board
#'
#' @param game A [dp_game] object.
#' @param power Optional power to filter on.
#' @return A tibble with columns `power`, `type`, `loc` and `province`.
#' @export
#' @family setup
#' @examples
#' dp_units(dp_new_game(), "Italy")
dp_units <- function(game, power = NULL) {
  .check_game(game)
  out <- game$units
  if (!is.null(power)) {
    power <- .match_power(power, game$powers)
    out <- out[out$power %in% power, , drop = FALSE]
  }
  out$province <- .province(out$loc)
  out
}

#' Human-readable label for the current turn
#'
#' @param game A [dp_game] object.
#' @return A single string such as `"Spring 1901 movement"`.
#' @noRd
.turn_label <- function(game) {
  paste(game$season, game$year, game$phase)
}
