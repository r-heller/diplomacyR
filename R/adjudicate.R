# The engine ------------------------------------------------------------------
#
# Diplomacy is adjudicated simultaneously, and the outcome of one order can
# depend on the outcome of another that in turn depends on the first. The
# resolver below is the standard guess-and-check algorithm: adjudicate an order
# under the guess that it fails, then under the guess that it succeeds. If both
# guesses agree the order is settled; if they disagree the orders form a cycle
# and a backup rule breaks it -- circular movement resolves in favour of all
# the movers, a convoy paradox is broken by disrupting the convoy.

#' Construct an adjudication result
#'
#' @param orders The effective orders, with `success` and `note` columns.
#' @param units Unit positions after the phase.
#' @param dislodged Units dislodged by the phase.
#' @param contested Provinces where a standoff occurred.
#' @param season Season of the adjudicated phase.
#' @param year Year of the adjudicated phase.
#' @param phase Phase that was adjudicated.
#' @param disbanded Units removed from the board by the phase.
#' @param built Units added to the board by the phase.
#' @return An object of class `dp_result`.
#' @noRd
new_dp_result <- function(orders, units, dislodged, contested, season, year,
                          phase, disbanded = .empty_units(),
                          built = .empty_units()) {
  structure(
    list(
      orders = orders,
      units = units,
      dislodged = dislodged,
      contested = contested,
      disbanded = disbanded,
      built = built,
      season = season,
      year = as.integer(year),
      phase = phase
    ),
    class = "dp_result"
  )
}

#' Validate an adjudication result
#'
#' @param x A candidate `dp_result`.
#' @param call Caller environment, for error reporting.
#' @return `x`, validated.
#' @noRd
validate_dp_result <- function(x, call = rlang::caller_env()) {
  .check_class(x, "dp_result", call = call)
  if (!"success" %in% names(x$orders)) {
    cli::cli_abort("A {.cls dp_result} must record order success.", call = call)
  }
  x
}

#' Test whether an object is an adjudication result
#'
#' @param x An object to test.
#' @return A logical scalar.
#' @export
#' @family engine
#' @examples
#' is_dp_result(dp_adjudicate(dp_new_game(), dp_example_orders()))
is_dp_result <- function(x) inherits(x, "dp_result")

#' Coerce orders supplied as text
#'
#' @param orders A `dp_orders` tibble or character vector.
#' @param game A [dp_game] object.
#' @param call Caller environment, for error reporting.
#' @return A `dp_orders` tibble.
#' @noRd
.as_orders <- function(orders, game, call = rlang::caller_env()) {
  if (is.null(orders)) return(.empty_orders())
  if (is.character(orders)) {
    return(dp_parse_orders(orders, phase = game$phase, map = game$map,
                           call = call))
  }
  .check_class(orders, "dp_orders", call = call)
  orders
}

#' Is there any conceivable convoy chain for a move?
#'
#' Ignores dislodgement: this decides whether a move counts as convoyed at all.
#'
#' @param map A [dp_map] object.
#' @param src Source province.
#' @param dst Destination province.
#' @param seas Sea provinces whose fleets are ordered to convoy the move.
#' @return `TRUE` when a chain of those seas links source to destination.
#' @noRd
.potential_convoy_path <- function(map, src, dst, seas) {
  if (length(seas) == 0L) return(FALSE)
  if (.province_type(map, src) != "coast") return(FALSE)
  if (.province_type(map, dst) != "coast") return(FALSE)
  frontier <- intersect(.adjacent_seas(map, src), seas)
  seen <- character(0)
  while (length(frontier) > 0L) {
    if (any(vapply(frontier, function(s) dst %in% .adjacent_coasts(map, s),
                   logical(1)))) {
      return(TRUE)
    }
    seen <- union(seen, frontier)
    nxt <- unique(unlist(
      lapply(frontier, function(s) intersect(.adjacent_seas(map, s), seas)),
      use.names = FALSE
    ))
    frontier <- setdiff(nxt, seen)
  }
  FALSE
}

#' Reduce submitted orders to one legal order per unit
#'
#' Units without an order, and units whose order breaks the rules, hold.
#'
#' @param game A [dp_game] object.
#' @param orders A `dp_orders` tibble.
#' @return A `dp_orders` tibble with one row per unit, plus a `note` column.
#' @noRd
.legalise_orders <- function(game, orders) {
  units <- game$units
  n <- nrow(units)
  eff <- tibble::tibble(
    power = units$power,
    type = rep("hold", n),
    unit_type = units$type,
    loc = units$loc,
    target = rep(NA_character_, n),
    aux_type = rep(NA_character_, n),
    aux_loc = rep(NA_character_, n),
    aux_target = rep(NA_character_, n),
    via_convoy = rep(FALSE, n),
    note = rep("no order (holds)", n)
  )
  if (nrow(orders) == 0L) return(eff)

  orders <- .fill_unit_types(orders, game)
  idx <- .unit_index(units, .province(orders$loc))
  reach <- .convoy_reach_table(game)
  taken <- rep(FALSE, n)

  for (k in seq_len(nrow(orders))) {
    i <- idx[k]
    if (is.na(i)) next
    if (taken[i]) next
    if (orders$power[k] != units$power[i]) next
    o <- orders[k, ]
    verdict <- .check_movement_legality(game, units, i, o, reach)
    if (!is.null(verdict$error)) {
      eff$note[i] <- verdict$error
      taken[i] <- TRUE
      next
    }
    eff$type[i] <- o$type
    eff$target[i] <- verdict$target
    eff$aux_type[i] <- o$aux_type
    eff$aux_loc[i] <- .province(o$aux_loc)
    eff$aux_target[i] <- o$aux_target
    eff$via_convoy[i] <- isTRUE(o$via_convoy)
    eff$note[i] <- "ordered"
    taken[i] <- TRUE
  }
  eff
}

#' Legality of one movement-phase order
#'
#' @param game A [dp_game] object.
#' @param units The units tibble.
#' @param i Index of the ordered unit.
#' @param o One-row order tibble.
#' @param reach Convoy reachability table for the current board.
#' @return A list with `target` and, when the order is void, `error`.
#' @noRd
.check_movement_legality <- function(game, units, i, o, reach) {
  map <- game$map
  ok <- function(target = NA_character_) list(target = target, error = NULL)
  no <- function(msg) list(target = NA_character_, error = msg)

  if (o$type %in% c("retreat", "build", "disband", "waive")) {
    return(no("not a movement order (holds)"))
  }
  if (o$type == "hold") return(ok())

  utype <- units$type[i]
  src <- units$loc[i]

  if (o$type == "move") {
    dst <- tolower(o$target)
    if (.province(dst) == .province(src)) return(no("cannot move to itself"))
    if (utype == "fleet") {
      adj <- .fleet_moves(map, src)
      if (dst %in% adj) return(ok(dst))
      cs <- .coasts_of(map, .province(dst))
      if (length(cs) > 0L && is.na(.coast(dst))) {
        # A single reachable coast is unambiguous; two are not.
        open <- intersect(cs, adj)
        if (length(open) == 1L) return(ok(open))
        if (length(open) > 1L) return(no("coast not specified (holds)"))
      }
      return(no("illegal move (holds)"))
    }
    if (.province(dst) %in% (map$army_adj[[.province(src)]] %||%
                             character(0))) {
      return(ok(.province(dst)))
    }
    # An army ordered to a province it does not border is attempting a convoy.
    # The order stands -- and fails if no chain actually carries it -- as long
    # as the fleets on the board make a convoy conceivable. If no such fleets
    # exist the order is simply impossible and the army holds.
    if (.province(dst) %in% (reach[[.province(src)]] %||% character(0))) {
      return(ok(.province(dst)))
    }
    return(no("illegal move (holds)"))
  }

  if (o$type == "support") {
    aux <- .province(o$aux_loc)
    if (identical(aux, .province(src))) return(no("cannot support itself"))
    if (is.na(.unit_index(units, aux))) {
      return(no("supports an empty province (holds)"))
    }
    dest <- if (is.na(o$aux_target)) aux else .province(o$aux_target)
    reach <- if (utype == "army") {
      map$army_adj[[.province(src)]] %||% character(0)
    } else {
      .province(.fleet_moves(map, src))
    }
    if (!dest %in% .province(reach)) {
      return(no("cannot reach the supported province (holds)"))
    }
    return(ok())
  }

  if (o$type == "convoy") {
    if (utype != "fleet") return(no("only fleets convoy (holds)"))
    if (.province_type(map, src) != "sea") {
      return(no("convoying fleet must be at sea (holds)"))
    }
    aux <- .province(o$aux_loc)
    j <- .unit_index(units, aux)
    if (is.na(j) || units$type[j] != "army") {
      return(no("convoys a unit that is not an army (holds)"))
    }
    return(ok())
  }
  no("unknown order (holds)")
}

#' Sea provinces ordered to convoy a particular move
#'
#' @param orders All submitted orders.
#' @param convoy_rows Row indices of convoy orders.
#' @param src Source province of the convoyed army.
#' @param dst Destination province.
#' @return A character vector of sea provinces.
#' @noRd
.convoy_seas_for <- function(orders, convoy_rows, src, dst) {
  if (length(convoy_rows) == 0L) return(character(0))
  keep <- convoy_rows[
    .province(orders$aux_loc[convoy_rows]) == src &
      .province(orders$aux_target[convoy_rows]) == dst
  ]
  unique(.province(orders$loc[keep]))
}

#' Build the resolver state
#'
#' @param game A [dp_game] object.
#' @param eff Legalised orders, one row per unit.
#' @return An environment holding the resolver state.
#' @noRd
.resolver_state <- function(game, eff) {
  map <- game$map
  units <- game$units
  n <- nrow(eff)
  st <- new.env(parent = emptyenv())
  st$map <- map
  st$units <- units
  st$orders <- eff
  st$n <- n
  st$state <- rep(0L, n)
  st$result <- rep(FALSE, n)
  st$dep <- integer(0)
  st$touch <- integer(0)

  st$order_at <- stats::setNames(as.list(seq_len(n)), .province(units$loc))

  moves <- which(eff$type == "move")
  st$moves_into <- split(moves, .province(eff$target[moves]))

  convoys <- which(eff$type == "convoy")
  st$is_convoy <- rep(FALSE, n)
  st$convoy_for <- vector("list", n)
  for (i in moves) {
    if (eff$unit_type[i] != "army") next
    src <- .province(eff$loc[i])
    dst <- .province(eff$target[i])
    cv <- convoys[
      .province(eff$aux_loc[convoys]) == src &
        .province(eff$aux_target[convoys]) == dst
    ]
    st$convoy_for[[i]] <- cv
    adjacent <- dst %in% (map$army_adj[[src]] %||% character(0))
    if (!adjacent) {
      # No land route: the army travels by convoy, and the move simply fails
      # if no chain carries it.
      st$is_convoy[i] <- TRUE
      next
    }
    # Both routes are available, so intent decides. Intent to convoy is shown
    # by ordering "via convoy", or by one of the army's own fleets sitting on
    # a possible convoy route. A foreign convoy order cannot commandeer the
    # army, and neither can a friendly fleet that is nowhere near the route.
    if (length(cv) == 0L ||
        !.potential_convoy_path(map, src, dst, .province(eff$loc[cv]))) {
      next
    }
    on_route <- .seas_on_possible_route(map, src, dst)
    own <- any(eff$power[cv][.province(eff$loc[cv]) %in% on_route] ==
                 eff$power[i])
    if (own || isTRUE(eff$via_convoy[i])) st$is_convoy[i] <- TRUE
  }

  sup <- which(eff$type == "support")
  sup_move <- sup[!is.na(eff$aux_target[sup])]
  # A support only backs a move that was actually ordered. Support is given at
  # province level, but a support that names a coast must name the right one.
  keep <- vapply(sup_move, function(j) {
    k <- st$order_at[[.province(eff$aux_loc[j])]] %||% NA_integer_
    if (is.na(k) || eff$type[k] != "move") return(FALSE)
    if (.province(eff$target[k]) != .province(eff$aux_target[j])) return(FALSE)
    sc <- .coast(eff$aux_target[j])
    mc <- .coast(eff$target[k])
    is.na(sc) || is.na(mc) || identical(sc, mc)
  }, logical(1))
  sup_move <- sup_move[keep]
  st$support_move <- split(
    sup_move,
    paste0(.province(eff$aux_loc[sup_move]), ">",
           .province(eff$aux_target[sup_move]))
  )
  sup_hold <- sup[is.na(eff$aux_target[sup])]
  st$support_hold <- split(sup_hold, .province(eff$aux_loc[sup_hold]))
  st
}

#' Does a move have a usable path?
#'
#' @param st Resolver state environment.
#' @param i Index of the move order.
#' @return `TRUE` when the unit can physically make the move.
#' @noRd
.path_successful <- function(st, i) {
  if (st$orders$type[i] != "move") return(FALSE)
  if (!st$is_convoy[i]) return(TRUE)
  .convoy_path_ok(st, i)
}

#' Adjudicate a single order under the current guesses
#'
#' @param st Resolver state environment.
#' @param i Order index.
#' @return `TRUE` when the order succeeds.
#' @noRd
.adjudicate_order <- function(st, i) {
  switch(st$orders$type[i],
    hold = TRUE,
    move = .adjudicate_move(st, i),
    support = .adjudicate_support(st, i),
    convoy = .adjudicate_convoy(st, i),
    TRUE
  )
}

#' Resolve one order, guessing and checking as needed
#'
#' @param st Resolver state environment.
#' @param i Order index.
#' @return `TRUE` when the order succeeds.
#' @noRd
.resolve <- function(st, i) {
  if (st$state[i] == 2L) return(st$result[i])
  if (st$state[i] == 1L) {
    # A guess was consulted: record it so the caller knows its own answer is
    # provisional, and note the order as part of the dependency chain.
    if (!i %in% st$dep) st$dep <- c(st$dep, i)
    st$touch <- c(st$touch, i)
    return(st$result[i])
  }
  old_nr <- length(st$dep)
  k0 <- length(st$touch)
  st$state[i] <- 1L
  st$result[i] <- FALSE
  first <- .adjudicate_order(st, i)

  if (length(.pending_touch(st, k0, i)) == 0L) {
    st$touch <- st$touch[seq_len(k0)]
    if (st$state[i] != 2L) {
      st$state[i] <- 2L
      st$result[i] <- first
    }
    return(st$result[i])
  }
  heads_cycle <- length(st$dep) > old_nr && st$dep[old_nr + 1L] == i
  if (!heads_cycle) {
    pending <- .pending_touch(st, k0, i)
    if (!i %in% st$dep) st$dep <- c(st$dep, i)
    st$touch <- c(st$touch[seq_len(k0)], pending, i)
    st$result[i] <- first
    return(first)
  }

  .pop_dep(st, old_nr)
  st$touch <- st$touch[seq_len(k0)]
  st$state[i] <- 1L
  st$result[i] <- TRUE
  second <- .adjudicate_order(st, i)

  if (identical(first, second)) {
    .pop_dep(st, old_nr)
    st$touch <- st$touch[seq_len(k0)]
    st$state[i] <- 2L
    st$result[i] <- first
    return(first)
  }
  .backup_rule(st, old_nr)
  st$touch <- st$touch[seq_len(k0)]
  .resolve(st, i)
}

#' Orders consulted while still guessing during the current adjudication
#'
#' @param st Resolver state environment.
#' @param k0 Length of the touch log before the adjudication began.
#' @param i The order being adjudicated, which never counts as its own
#'   dependency.
#' @return An integer vector of order indices still in the guessing state.
#' @noRd
.pending_touch <- function(st, k0, i) {
  if (length(st$touch) <= k0) return(integer(0))
  hit <- unique(st$touch[seq.int(k0 + 1L, length(st$touch))])
  hit <- hit[hit != i]
  hit[st$state[hit] == 1L]
}

#' Unwind the dependency stack back to a mark
#'
#' @param st Resolver state environment.
#' @param old_nr Stack size to unwind to.
#' @return The indices removed, invisibly.
#' @noRd
.pop_dep <- function(st, old_nr) {
  if (length(st$dep) <= old_nr) return(invisible(integer(0)))
  gone <- st$dep[seq.int(old_nr + 1L, length(st$dep))]
  st$dep <- st$dep[seq_len(old_nr)]
  st$state[gone] <- 0L
  invisible(gone)
}

#' Break a cycle of mutually dependent orders
#'
#' Circular movement resolves in favour of every mover. A cycle that involves
#' a convoy is a convoy paradox and is broken by disrupting the convoys, which
#' is the Szykman rule.
#'
#' @param st Resolver state environment.
#' @param old_nr Stack size marking the start of the cycle.
#' @return Nothing, called for its effect on `st`.
#' @noRd
.backup_rule <- function(st, old_nr) {
  cycle <- st$dep[seq.int(old_nr + 1L, length(st$dep))]
  st$dep <- st$dep[seq_len(old_nr)]
  st$state[cycle] <- 0L
  types <- st$orders$type[cycle]
  if (all(types == "move")) {
    st$state[cycle] <- 2L
    st$result[cycle] <- TRUE
    return(invisible(NULL))
  }
  if (any(types == "convoy")) {
    hit <- cycle[types == "convoy"]
    st$state[hit] <- 2L
    st$result[hit] <- FALSE
    return(invisible(NULL))
  }
  st$state[cycle] <- 2L
  st$result[cycle] <- st$orders$type[cycle] != "move"
  invisible(NULL)
}

#' Adjudicate a movement phase
#'
#' Resolves every order simultaneously under the standard rules: support
#' counting and support cutting, convoy path resolution including the paradox
#' cases, standoffs, dislodgement, and the prohibitions on self-dislodgement
#' and self-standoff. Units with no order, or with an order that breaks the
#' rules, hold.
#'
#' The implementation follows the Diplomacy Adjudicator Test Cases (DATC); the
#' encoded cases ship with the package under `extdata/datc`.
#'
#' @param game A [dp_game] object in a movement phase.
#' @param orders A `dp_orders` tibble, or a character vector of orders in
#'   standard notation.
#' @param call Caller environment, for error reporting. Experts only.
#' @return A [dp_result] object recording, per order, whether it succeeded,
#'   plus the resulting unit positions, the dislodged units and the provinces
#'   where a standoff occurred. Feed it to [dp_advance()] for the next state.
#' @export
#' @family engine
#' @examples
#' g <- dp_new_game()
#' res <- dp_adjudicate(g, dp_example_orders("spring_1901"))
#' res
dp_adjudicate <- function(game, orders, call = rlang::caller_env()) {
  .check_game(game, call = call)
  if (game$phase != "movement") {
    cli::cli_abort(
      c("{.fn dp_adjudicate} resolves movement phases.",
        i = "This game is in the {.val {game$phase}} phase; use \\
             {.fn dp_retreat} or {.fn dp_build}."),
      call = call
    )
  }
  orders <- .as_orders(orders, game, call = call)
  eff <- .legalise_orders(game, orders)

  if (nrow(eff) == 0L) {
    return(validate_dp_result(new_dp_result(
      orders = .result_orders(eff, logical(0)),
      units = .empty_units(), dislodged = .empty_dislodged(),
      contested = character(0), season = game$season, year = game$year,
      phase = "movement"
    ), call = call))
  }

  st <- .resolver_state(game, eff)
  for (i in seq_len(st$n)) .resolve(st, i)
  outcome <- .collect_outcome(st)

  validate_dp_result(new_dp_result(
    orders = .result_orders(st$orders, st$result),
    units = outcome$units,
    dislodged = outcome$dislodged,
    contested = outcome$contested,
    season = game$season,
    year = game$year,
    phase = "movement"
  ), call = call)
}

#' Attach success flags to the effective orders
#'
#' @param eff Legalised orders.
#' @param success Logical vector of outcomes.
#' @return A `dp_orders` tibble with `success` and `note` columns.
#' @noRd
.result_orders <- function(eff, success) {
  eff$success <- success
  new_dp_orders(eff)
}
