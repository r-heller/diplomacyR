# Winter adjustments -----------------------------------------------------------

#' Adjudicate a build phase
#'
#' Reconciles each power's unit count with its supply-centre count. A power
#' with centres to spare may build in its own home centres, provided it still
#' owns them and they are empty; fleets may only be built in coastal home
#' centres, naming a coast where the province has more than one. A power with
#' too many units must disband the difference, and any shortfall in its orders
#' is made up by the civil-disorder rule: the unit furthest from home goes
#' first, a fleet before an army at equal distance, ties broken alphabetically.
#'
#' @param game A [dp_game] object in a build phase.
#' @param orders A `dp_orders` tibble, or a character vector of orders such as
#'   `"Build A Par"` and `"Remove F Bre"`.
#' @param call Caller environment, for error reporting. Experts only.
#' @return A [dp_result] object with the new unit positions, the units built
#'   and the units disbanded.
#' @export
#' @family engine
#' @examples
#' g <- dp_example_game("build")
#' dp_build(g, "Germany: Build A Ber")
dp_build <- function(game, orders = NULL, call = rlang::caller_env()) {
  .check_game(game, call = call)
  if (game$phase != "build") {
    cli::cli_abort(
      c("{.fn dp_build} resolves adjustment phases.",
        i = "This game is in the {.val {game$phase}} phase."),
      call = call
    )
  }
  orders <- .as_orders(orders, game, call = call)
  units <- game$units
  built <- .empty_units()
  removed_idx <- integer(0)
  rows <- vector("list", 0L)

  for (pw in game$powers) {
    delta <- .build_delta(game, pw)
    own <- orders[orders$power == pw, , drop = FALSE]
    if (delta > 0L) {
      res <- .resolve_builds(game, pw, own, delta, built)
      built <- res$built
      rows <- c(rows, list(res$rows))
    } else if (delta < 0L) {
      res <- .resolve_disbands(game, pw, own, -delta, removed_idx)
      removed_idx <- res$removed
      rows <- c(rows, list(res$rows))
    } else if (nrow(own) > 0L) {
      rows <- c(rows, list(.adjust_rows(own, FALSE, "no adjustment due")))
    }
  }

  keep <- setdiff(seq_len(nrow(units)), removed_idx)
  disbanded <- units[removed_idx, , drop = FALSE]
  new_units <- rbind(units[keep, , drop = FALSE], built)

  eff <- if (length(rows) == 0L) {
    .empty_adjust_rows()
  } else {
    do.call(rbind, rows)
  }

  validate_dp_result(new_dp_result(
    orders = new_dp_orders(eff),
    units = new_units,
    dislodged = .empty_dislodged(),
    contested = character(0),
    disbanded = tibble::as_tibble(disbanded),
    built = built,
    season = game$season,
    year = game$year,
    phase = "build"
  ), call = call)
}

#' Zero-row adjustment order table
#'
#' @return A zero-row tibble with the order columns plus `note` and `success`.
#' @noRd
.empty_adjust_rows <- function() {
  out <- .empty_orders()
  out$note <- character(0)
  out$success <- logical(0)
  tibble::as_tibble(out)
}

#' Attach outcome columns to adjustment orders
#'
#' @param o A `dp_orders` tibble.
#' @param success Logical vector, recycled.
#' @param note Character vector, recycled.
#' @return A tibble with `note` and `success` columns.
#' @noRd
.adjust_rows <- function(o, success, note) {
  o <- tibble::as_tibble(o)[, names(.empty_orders()), drop = FALSE]
  o$note <- rep(note, length.out = nrow(o))
  o$success <- rep(success, length.out = nrow(o))
  o
}

#' Resolve the builds ordered by one power
#'
#' @param game A [dp_game] object.
#' @param pw The power.
#' @param own That power's orders.
#' @param allowed Number of builds due.
#' @param built Units built so far this phase.
#' @return A list with the updated `built` tibble and the reported `rows`.
#' @noRd
.resolve_builds <- function(game, pw, own, allowed, built) {
  rows <- vector("list", 0L)
  sites <- .build_sites(game, pw)
  used <- character(0)
  made <- 0L
  for (k in seq_len(nrow(own))) {
    o <- own[k, ]
    if (o$type == "waive") {
      made <- made + 1L
      rows <- c(rows, list(.adjust_rows(o, TRUE, "build waived")))
      next
    }
    if (o$type != "build") {
      rows <- c(rows, list(.adjust_rows(o, FALSE, "not a build order")))
      next
    }
    if (made >= allowed) {
      rows <- c(rows, list(.adjust_rows(o, FALSE, "no build left")))
      next
    }
    prov <- .province(o$loc)
    if (!prov %in% sites || prov %in% used) {
      rows <- c(rows, list(.adjust_rows(o, FALSE, "not an open home centre")))
      next
    }
    utype <- o$unit_type
    if (is.na(utype)) utype <- "army"
    loc <- tryCatch(
      .normalise_loc(game$map, o$loc, utype),
      error = function(e) NA_character_
    )
    if (is.na(loc)) {
      rows <- c(rows, list(.adjust_rows(o, FALSE, "illegal build location")))
      next
    }
    built <- rbind(built, tibble::tibble(power = pw, type = utype, loc = loc))
    used <- c(used, prov)
    made <- made + 1L
    rows <- c(rows, list(.adjust_rows(o, TRUE, "built")))
  }
  list(built = built,
       rows = if (length(rows)) do.call(rbind, rows) else .empty_adjust_rows())
}

#' Resolve the disbands owed by one power
#'
#' @param game A [dp_game] object.
#' @param pw The power.
#' @param own That power's orders.
#' @param required Number of units that must go.
#' @param removed Row indices removed so far this phase.
#' @return A list with the updated `removed` indices and the reported `rows`.
#' @noRd
.resolve_disbands <- function(game, pw, own, required, removed) {
  rows <- vector("list", 0L)
  units <- game$units
  gone <- integer(0)
  for (k in seq_len(nrow(own))) {
    o <- own[k, ]
    if (o$type != "disband") {
      rows <- c(rows, list(.adjust_rows(o, FALSE, "not a disband order")))
      next
    }
    if (length(gone) >= required) {
      rows <- c(rows, list(.adjust_rows(o, FALSE, "no disband left")))
      next
    }
    i <- .unit_index(units, .province(o$loc))
    if (is.na(i) || units$power[i] != pw || i %in% gone) {
      rows <- c(rows, list(.adjust_rows(o, FALSE, "no such unit")))
      next
    }
    gone <- c(gone, i)
    rows <- c(rows, list(.adjust_rows(o, TRUE, "disbanded")))
  }
  if (length(gone) < required) {
    fallback <- setdiff(.civil_disorder_order(game, pw), gone)
    extra <- utils::head(fallback, required - length(gone))
    if (length(extra) > 0L) {
      rows <- c(rows, list(.adjust_rows(
        tibble::tibble(
          power = pw, type = "disband", unit_type = units$type[extra],
          loc = units$loc[extra], target = NA_character_,
          aux_type = NA_character_, aux_loc = NA_character_,
          aux_target = NA_character_, via_convoy = FALSE
        ),
        TRUE, "civil disorder"
      )))
      gone <- c(gone, extra)
    }
  }
  list(removed = c(removed, gone),
       rows = if (length(rows)) do.call(rbind, rows) else .empty_adjust_rows())
}
