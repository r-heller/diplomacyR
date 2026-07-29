# Retreats --------------------------------------------------------------------

#' Where a dislodged unit may go
#'
#' A retreat must reach an adjacent, empty province that was not the source of
#' the attack -- unless that attack arrived by convoy -- and that was not left
#' empty by a standoff.
#'
#' @param game A [dp_game] object in a retreat phase.
#' @param unit A one-row slice of the dislodged tibble.
#' @return A character vector of legal destinations, possibly empty.
#' @noRd
.retreat_options <- function(game, unit) {
  map <- game$map
  dest <- if (unit$type == "army") {
    map$army_adj[[.province(unit$loc)]] %||% character(0)
  } else {
    .fleet_moves(map, unit$loc)
  }
  occupied <- .province(game$units$loc)
  dest <- dest[!.province(dest) %in% occupied]
  dest <- dest[!.province(dest) %in% game$contested]
  if (!isTRUE(unit$by_convoy)) {
    dest <- dest[.province(dest) != unit$from]
  }
  sort(unique(dest))
}

#' Adjudicate a retreat phase
#'
#' Each dislodged unit either retreats to a legal destination or is disbanded.
#' A unit with no order, with an order the rules forbid, or with no legal
#' destination at all, disbands. When two or more units retreat to the same
#' province they all disband.
#'
#' @param game A [dp_game] object in a retreat phase.
#' @param orders A `dp_orders` tibble, or a character vector of orders.
#'   Retreats may be written `"A Tri R Alb"` or, in a retreat phase, simply
#'   `"A Tri - Alb"`.
#' @param call Caller environment, for error reporting. Experts only.
#' @return A [dp_result] object with the surviving unit positions and the
#'   units that disbanded.
#' @export
#' @family engine
#' @examples
#' g <- dp_example_game("retreat")
#' dp_retreat(g, "Austria: A Tri R Alb")
dp_retreat <- function(game, orders = NULL, call = rlang::caller_env()) {
  .check_game(game, call = call)
  if (game$phase != "retreat") {
    cli::cli_abort(
      c("{.fn dp_retreat} resolves retreat phases.",
        i = "This game is in the {.val {game$phase}} phase."),
      call = call
    )
  }
  orders <- .as_orders(orders, game, call = call)
  d <- game$dislodged
  n <- nrow(d)

  eff <- tibble::tibble(
    power = d$power,
    type = rep("disband", n),
    unit_type = d$type,
    loc = d$loc,
    target = rep(NA_character_, n),
    aux_type = rep(NA_character_, n),
    aux_loc = rep(NA_character_, n),
    aux_target = rep(NA_character_, n),
    via_convoy = rep(FALSE, n),
    note = rep("no retreat ordered (disbands)", n)
  )

  if (n > 0L && nrow(orders) > 0L) {
    idx <- match(.province(orders$loc), .province(d$loc))
    taken <- rep(FALSE, n)
    for (k in seq_len(nrow(orders))) {
      i <- idx[k]
      if (is.na(i) || taken[i]) next
      if (orders$power[k] != d$power[i]) next
      taken[i] <- TRUE
      if (orders$type[k] %in% c("disband", "hold")) {
        eff$note[i] <- "disband ordered"
        next
      }
      if (orders$type[k] != "retreat") {
        eff$note[i] <- "not a retreat order (disbands)"
        next
      }
      opts <- .retreat_options(game, d[i, ])
      tgt <- tolower(orders$target[k])
      if (!tgt %in% opts) {
        # Accept a coast-free destination when only one coast is open.
        cs <- intersect(.coasts_of(game$map, .province(tgt)), opts)
        if (is.na(.coast(tgt)) && length(cs) == 1L) {
          tgt <- cs
        } else {
          eff$note[i] <- "illegal retreat (disbands)"
          next
        }
      }
      eff$type[i] <- "retreat"
      eff$target[i] <- tgt
      eff$note[i] <- "ordered"
    }
  }

  success <- eff$type == "retreat"
  if (any(success)) {
    dest <- .province(eff$target)
    clash <- dest[success][duplicated(dest[success])]
    bounced <- success & dest %in% clash
    success[bounced] <- FALSE
    eff$note[bounced] <- "retreats collide (disbands)"
  }

  moved <- tibble::tibble(
    power = eff$power[success],
    type = eff$unit_type[success],
    loc = eff$target[success]
  )
  disbanded <- tibble::tibble(
    power = eff$power[!success],
    type = eff$unit_type[!success],
    loc = eff$loc[!success]
  )
  eff$success <- success

  validate_dp_result(new_dp_result(
    orders = new_dp_orders(eff),
    units = rbind(game$units, moved),
    dislodged = .empty_dislodged(),
    contested = character(0),
    disbanded = disbanded,
    season = game$season,
    year = game$year,
    phase = "retreat"
  ), call = call)
}
