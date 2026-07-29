# The board -------------------------------------------------------------------

#' Construct a board object
#'
#' Low-level constructor for the `dp_map` S3 class: trusted input, no
#' validation. Use [dp_map()] instead.
#'
#' @param name Board name.
#' @param description One-line description of the board.
#' @param powers Character vector of the Great Powers.
#' @param provinces A tibble of provinces.
#' @param coasts Named list mapping province code to its named coasts.
#' @param army_adj Named list of army adjacency.
#' @param fleet_adj Named list of fleet adjacency, keyed by fleet location.
#' @param coast_xy A tibble of plotting coordinates for named coasts.
#' @param supply_centres Character vector of supply-centre province codes.
#' @param home_centres Named list mapping power to home supply centres.
#' @param start_units A tibble of the canonical starting position.
#' @return An object of class `dp_map`.
#' @noRd
new_dp_map <- function(name, description, powers, provinces, coasts,
                       army_adj, fleet_adj, coast_xy, supply_centres,
                       home_centres, start_units) {
  structure(
    list(
      name = name,
      description = description,
      powers = powers,
      provinces = provinces,
      coasts = coasts,
      army_adj = army_adj,
      fleet_adj = fleet_adj,
      coast_xy = coast_xy,
      supply_centres = supply_centres,
      home_centres = home_centres,
      start_units = start_units
    ),
    class = "dp_map"
  )
}

#' Validate a board object
#'
#' Checks the structural invariants of a `dp_map`: the province table is
#' complete, adjacency is symmetric for both the army and the fleet graph,
#' every split-coast province carries per-coast adjacency, and every supply
#' centre is a real province.
#'
#' @param x A candidate `dp_map` object.
#' @param call Caller environment, for error reporting.
#' @return `x`, invisibly validated.
#' @noRd
validate_dp_map <- function(x, call = rlang::caller_env()) {
  .check_class(x, "dp_map", call = call)
  prov <- x$provinces$code
  if (anyDuplicated(prov)) {
    cli::cli_abort("Province codes must be unique.", call = call)
  }
  if (!all(x$supply_centres %in% prov)) {
    bad <- setdiff(x$supply_centres, prov)
    cli::cli_abort(
      "Supply centre{?s} {.val {bad}} {?is/are} not on the board.",
      call = call
    )
  }
  for (side in c("army_adj", "fleet_adj")) {
    adj <- x[[side]]
    for (a in names(adj)) {
      for (b in adj[[a]]) {
        if (!a %in% adj[[b]]) {
          cli::cli_abort(
            "Adjacency is not symmetric: {.val {a}} borders {.val {b}} but \\
             not the reverse.",
            call = call
          )
        }
      }
    }
  }
  for (p in names(x$coasts)) {
    for (cst in x$coasts[[p]]) {
      loc <- paste0(p, "/", cst)
      if (is.null(x$fleet_adj[[loc]])) {
        cli::cli_abort(
          "Split-coast location {.val {loc}} has no fleet adjacency.",
          call = call
        )
      }
    }
  }
  invisible(x)
}

#' Load a Diplomacy board
#'
#' Reads a board definition shipped with the package and returns it as a
#' validated `dp_map` object. Only the standard seven-power pre-1914 map is
#' currently supplied: 75 provinces (56 land, 19 sea), 34 supply centres and
#' the canonical 22-unit opening position.
#'
#' @param name Board to load. Only `"standard"` is available.
#' @param call Caller environment, for error reporting. Experts only.
#' @return A [dp_map] object: a list with the province table, the army and
#'   fleet adjacency graphs, supply-centre and home-centre definitions, and
#'   the starting position.
#' @export
#' @family setup
#' @examples
#' m <- dp_map()
#' m
#' nrow(dp_provinces(m))
dp_map <- function(name = "standard", call = rlang::caller_env()) {
  .check_string(name, call = call)
  name <- rlang::arg_match(name, "standard", error_call = call)
  validate_dp_map(.load_standard_map(call = call), call = call)
}

#' Test whether an object is a board
#'
#' @param x An object to test.
#' @return A logical scalar.
#' @export
#' @family setup
#' @examples
#' is_dp_map(dp_map())
is_dp_map <- function(x) inherits(x, "dp_map")

# Accessors -------------------------------------------------------------------

#' List the provinces of a board
#'
#' @param map A [dp_map] object.
#' @param type Optional filter: one or more of `"land"`, `"coast"`, `"sea"`.
#' @return A tibble with one row per province and columns `code`, `name`,
#'   `type`, `supply_centre`, `home_power`, `x` and `y`.
#' @export
#' @family setup
#' @examples
#' dp_provinces(dp_map(), type = "sea")
dp_provinces <- function(map = dp_map(), type = NULL) {
  .check_class(map, "dp_map")
  out <- map$provinces
  if (!is.null(type)) {
    type <- rlang::arg_match(type, c("land", "coast", "sea"), multiple = TRUE)
    out <- out[out$type %in% type, , drop = FALSE]
  }
  out
}

#' Supply centres of a board or a game
#'
#' For a [dp_map] this lists the 34 supply centres of the board. For a
#' [dp_game] it additionally reports the current owner of each centre and
#' whether it is occupied.
#'
#' @param x A [dp_map] or [dp_game] object.
#' @param ... Passed to methods.
#' @return A tibble. For a map: `centre`, `name`, `home_power`. For a game:
#'   `centre`, `name`, `home_power`, `owner`, `occupied_by`.
#' @export
#' @family analysis
#' @examples
#' dp_supply_centres(dp_map())
#' dp_supply_centres(dp_new_game())
dp_supply_centres <- function(x, ...) {
  UseMethod("dp_supply_centres")
}

#' @rdname dp_supply_centres
#' @export
dp_supply_centres.dp_map <- function(x, ...) {
  rlang::check_dots_empty()
  p <- x$provinces
  p <- p[p$supply_centre, c("code", "name", "home_power"), drop = FALSE]
  names(p)[1] <- "centre"
  p
}

#' Neighbours of a location
#'
#' Returns the locations a unit of the given type may move to in one step.
#' For fleets, split-coast provinces are addressed by their named coasts
#' (`"spa/nc"`, `"bul/ec"`, `"stp/sc"`, ...).
#'
#' @param map A [dp_map] object.
#' @param loc A location code, such as `"par"` or `"spa/nc"`.
#' @param unit_type `"army"` or `"fleet"`.
#' @param call Caller environment, for error reporting. Experts only.
#' @return A character vector of neighbouring locations, possibly empty.
#' @export
#' @family setup
#' @examples
#' dp_adjacent(dp_map(), "par", "army")
#' dp_adjacent(dp_map(), "spa/nc", "fleet")
dp_adjacent <- function(map, loc, unit_type = c("army", "fleet"),
                        call = rlang::caller_env()) {
  .check_class(map, "dp_map", call = call)
  .check_string(loc, call = call)
  unit_type <- rlang::arg_match(unit_type, error_call = call)
  loc <- tolower(loc)
  if (!.province(loc) %in% map$provinces$code) {
    cli::cli_abort("Unknown province {.val {(.province(loc))}}.", call = call)
  }
  if (unit_type == "army") {
    out <- map$army_adj[[.province(loc)]]
  } else {
    out <- map$fleet_adj[[loc]]
  }
  out %||% character(0)
}

#' Home supply centres
#'
#' @param map A [dp_map] object.
#' @param power Optional power to filter on.
#' @return A tibble with columns `power` and `centre`.
#' @export
#' @family setup
#' @examples
#' dp_home_centres(dp_map(), "France")
dp_home_centres <- function(map = dp_map(), power = NULL) {
  .check_class(map, "dp_map")
  hc <- map$home_centres
  out <- tibble::tibble(
    power = rep(names(hc), lengths(hc)),
    centre = unlist(hc, use.names = FALSE)
  )
  if (!is.null(power)) {
    power <- .match_power(power, map$powers)
    out <- out[out$power %in% power, , drop = FALSE]
  }
  out
}

#' All fleet locations of a board
#'
#' @param map A [dp_map] object.
#' @return A character vector of locations a fleet may occupy.
#' @noRd
.fleet_locations <- function(map) names(map$fleet_adj)

#' Named coasts of a province
#'
#' @param map A [dp_map] object.
#' @param province A province code.
#' @return A character vector of full coast locations, possibly empty.
#' @noRd
.coasts_of <- function(map, province) {
  cs <- map$coasts[[province]] %||% character(0)
  if (length(cs) == 0L) character(0) else paste0(province, "/", cs)
}

#' Type of a province
#'
#' @param map A [dp_map] object.
#' @param loc A location or province code.
#' @return `"land"`, `"coast"`, `"sea"`, or `NA_character_`.
#' @noRd
.province_type <- function(map, loc) {
  p <- .province(loc)
  idx <- match(p, map$provinces$code)
  ifelse(is.na(idx), NA_character_, map$provinces$type[idx])
}
