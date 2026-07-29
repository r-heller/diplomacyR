# Orders ----------------------------------------------------------------------

.order_types <- c(
  "hold", "move", "support", "convoy", "retreat", "build", "disband", "waive"
)

#' Construct an orders tibble
#'
#' Low-level constructor for the `dp_orders` S3 class: trusted input, no
#' validation. Use [dp_order()] or [dp_parse_orders()] instead.
#'
#' @param x A tibble with the canonical order columns.
#' @return An object of class `dp_orders`.
#' @noRd
new_dp_orders <- function(x) {
  stopifnot(is.data.frame(x))
  structure(
    tibble::as_tibble(x),
    class = c("dp_orders", "tbl_df", "tbl", "data.frame")
  )
}

#' Validate an orders tibble
#'
#' @param x A candidate `dp_orders` object.
#' @param call Caller environment, for error reporting.
#' @return `x`, invisibly validated.
#' @noRd
validate_dp_orders <- function(x, call = rlang::caller_env()) {
  .check_class(x, "dp_orders", call = call)
  need <- names(.empty_orders())
  miss <- setdiff(need, names(x))
  if (length(miss) > 0L) {
    cli::cli_abort("A {.cls dp_orders} tibble is missing column{?s} \\
                    {.val {miss}}.", call = call)
  }
  bad <- setdiff(x$type, .order_types)
  if (length(bad) > 0L) {
    cli::cli_abort(
      c("Unknown order type{?s} {.val {bad}}.",
        i = "Order types are {.val {.order_types}}."),
      call = call
    )
  }
  invisible(x)
}

#' Construct a Diplomacy order
#'
#' Builds a single order as a one-row `dp_orders` tibble. Orders are combined
#' with [rbind()] or [dp_bind_orders()], and rendered back to standard
#' notation by [format()].
#'
#' @param power Ordering power, for example `"France"`.
#' @param type One of `"hold"`, `"move"`, `"support"`, `"convoy"`,
#'   `"retreat"`, `"build"`, `"disband"` or `"waive"`.
#' @param unit Location of the ordered unit, for example `"par"` or
#'   `"spa/nc"`. Ignored for `"waive"`.
#' @param target Destination province for moves, retreats and builds, or
#'   `NULL`.
#' @param aux For supports and convoys, the order being supported or
#'   convoyed: either a single province (a unit ordered to hold) or a length-2
#'   vector `c(from, to)`, or the string `"from-to"`.
#' @param unit_type `"army"` or `"fleet"`. Required for builds; otherwise
#'   inferred from `map` when possible.
#' @param aux_type `"army"` or `"fleet"` for the supported or convoyed unit.
#' @param via_convoy Force a move to be routed by convoy. Default `FALSE`.
#' @param map A [dp_map] object used to validate locations.
#' @param call Caller environment, for error reporting. Experts only.
#' @return A one-row `dp_orders` tibble with columns `power`, `type`,
#'   `unit_type`, `loc`, `target`, `aux_type`, `aux_loc`, `aux_target` and
#'   `via_convoy`.
#' @export
#' @family orders
#' @examples
#' dp_order("France", "move", "par", target = "bur")
#' dp_order("England", "support", "lon", aux = c("wal", "yor"))
#' dp_order("England", "convoy", "nth", aux = "lon-nwy")
dp_order <- function(power, type, unit = NULL, target = NULL, aux = NULL,
                     unit_type = NULL, aux_type = NULL, via_convoy = FALSE,
                     map = dp_map(), call = rlang::caller_env()) {
  .check_class(map, "dp_map", call = call)
  type <- rlang::arg_match(type, .order_types, error_call = call)
  .check_flag(via_convoy, call = call)
  power <- .match_power(power, map$powers, call = call)

  loc <- if (is.null(unit)) NA_character_ else tolower(unit)
  if (!is.na(loc) && !.province(loc) %in% map$provinces$code) {
    cli::cli_abort("Unknown province {.val {.province(loc)}}.", call = call)
  }
  tgt <- if (is.null(target)) NA_character_ else tolower(target)

  aux_loc <- NA_character_
  aux_tgt <- NA_character_
  if (!is.null(aux)) {
    if (length(aux) == 1L && grepl("-", aux, fixed = TRUE)) {
      aux <- trimws(strsplit(aux, "-", fixed = TRUE)[[1]])
    }
    aux <- tolower(aux)
    aux_loc <- aux[1]
    if (length(aux) > 1L) aux_tgt <- aux[2]
  }

  if (type %in% c("support", "convoy") && is.na(aux_loc)) {
    cli::cli_abort(
      "{.arg aux} is required for {.val {type}} orders.",
      call = call
    )
  }
  if (type %in% c("move", "retreat") && is.na(tgt)) {
    cli::cli_abort(
      "{.arg target} is required for {.val {type}} orders.",
      call = call
    )
  }
  if (type == "build" && is.null(unit_type)) {
    cli::cli_abort(
      "{.arg unit_type} is required for {.val build} orders.",
      call = call
    )
  }

  ut <- unit_type %||% NA_character_
  if (!is.na(ut)) {
    ut <- rlang::arg_match0(ut, c("army", "fleet"), error_call = call)
  }
  at <- aux_type %||% NA_character_
  if (!is.na(at)) {
    at <- rlang::arg_match0(at, c("army", "fleet"), error_call = call)
  }

  validate_dp_orders(new_dp_orders(tibble::tibble(
    power = power,
    type = type,
    unit_type = ut,
    loc = loc,
    target = tgt,
    aux_type = at,
    aux_loc = aux_loc,
    aux_target = aux_tgt,
    via_convoy = via_convoy
  )), call = call)
}

#' Combine orders
#'
#' @param ... `dp_orders` tibbles to stack, in order.
#' @return A `dp_orders` tibble containing every input row.
#' @export
#' @family orders
#' @examples
#' a <- dp_order("France", "move", "par", target = "bur")
#' b <- dp_order("France", "hold", "mar")
#' dp_bind_orders(a, b)
dp_bind_orders <- function(...) {
  parts <- list(...)
  parts <- Filter(function(x) !is.null(x), parts)
  if (length(parts) == 0L) return(.empty_orders())
  out <- do.call(rbind, lapply(parts, function(x) {
    x <- tibble::as_tibble(x)
    x[, names(.empty_orders()), drop = FALSE]
  }))
  new_dp_orders(out)
}

#' Test whether an object is an orders tibble
#'
#' @param x An object to test.
#' @return A logical scalar.
#' @export
#' @family orders
#' @examples
#' is_dp_orders(dp_order("France", "hold", "par"))
is_dp_orders <- function(x) inherits(x, "dp_orders")

#' Fill in the unit type of each order from the board
#'
#' @param orders A `dp_orders` tibble.
#' @param game A [dp_game] object.
#' @return The orders with `unit_type` and `aux_type` completed where the
#'   board makes them unambiguous.
#' @noRd
.fill_unit_types <- function(orders, game) {
  if (nrow(orders) == 0L) return(orders)
  units <- game$units
  idx <- .unit_index(units, .province(orders$loc))
  fill <- is.na(orders$unit_type) & !is.na(idx)
  orders$unit_type[fill] <- units$type[idx[fill]]
  aidx <- .unit_index(units, .province(orders$aux_loc))
  afill <- is.na(orders$aux_type) & !is.na(aidx)
  orders$aux_type[afill] <- units$type[aidx[afill]]
  orders
}

#' Enumerate the legal orders available to a power
#'
#' Lists every order a power may legally issue in the current phase: holds,
#' moves (including convoyed moves), supports and convoys during movement;
#' retreats and disbands during a retreat phase; builds and disbands during an
#' adjustment phase. Bots and the Shiny order editor both use this to stay
#' inside the rules.
#'
#' @param game A [dp_game] object.
#' @param power The power to enumerate orders for. `NULL` enumerates every
#'   power.
#' @param unit Optional location; restricts the result to that unit.
#' @param call Caller environment, for error reporting. Experts only.
#' @return A `dp_orders` tibble, possibly with zero rows.
#' @export
#' @family orders
#' @examples
#' g <- dp_new_game()
#' head(dp_legal_orders(g, "France"))
dp_legal_orders <- function(game, power = NULL, unit = NULL,
                            call = rlang::caller_env()) {
  .check_game(game, call = call)
  if (!is.null(power)) power <- .match_power(power, game$powers, call = call)

  switch(game$phase,
    movement = .legal_movement_orders(game, power, unit),
    retreat = .legal_retreat_orders(game, power, unit),
    build = .legal_build_orders(game, power)
  )
}

#' @noRd
.legal_movement_orders <- function(game, power = NULL, unit = NULL) {
  map <- game$map
  units <- game$units
  if (!is.null(power)) units <- units[units$power %in% power, , drop = FALSE]
  if (!is.null(unit)) {
    units <- units[.province(units$loc) %in% .province(tolower(unit)), ,
                   drop = FALSE]
  }
  if (nrow(units) == 0L) return(.empty_orders())

  all_units <- game$units
  reach <- .convoy_reach_table(game)
  conv_to <- function(prov) reach[[prov]] %||% character(0)
  out <- vector("list", 0L)

  for (i in seq_len(nrow(units))) {
    u <- units[i, ]
    dest <- if (u$type == "army") {
      map$army_adj[[.province(u$loc)]] %||% character(0)
    } else {
      .fleet_moves(map, u$loc)
    }
    out[[length(out) + 1L]] <- tibble::tibble(
      power = u$power, type = "hold", unit_type = u$type, loc = u$loc,
      target = NA_character_, aux_type = NA_character_,
      aux_loc = NA_character_, aux_target = NA_character_, via_convoy = FALSE
    )
    if (length(dest) > 0L) {
      out[[length(out) + 1L]] <- tibble::tibble(
        power = u$power, type = "move", unit_type = u$type, loc = u$loc,
        target = dest, aux_type = NA_character_, aux_loc = NA_character_,
        aux_target = NA_character_, via_convoy = FALSE
      )
    }
    # Convoyed moves: any coastal province reachable through a sea chain of
    # friendly-or-not fleets currently on the board.
    if (u$type == "army") {
      conv <- conv_to(.province(u$loc))
      conv <- setdiff(conv, c(dest, .province(u$loc)))
      if (length(conv) > 0L) {
        out[[length(out) + 1L]] <- tibble::tibble(
          power = u$power, type = "move", unit_type = u$type, loc = u$loc,
          target = conv, aux_type = NA_character_, aux_loc = NA_character_,
          aux_target = NA_character_, via_convoy = TRUE
        )
      }
    }
    # Supports.
    for (d in dest) {
      other <- .unit_at(all_units, .province(d))
      if (nrow(other) == 1L && .province(other$loc) != .province(u$loc)) {
        out[[length(out) + 1L]] <- tibble::tibble(
          power = u$power, type = "support", unit_type = u$type, loc = u$loc,
          target = NA_character_, aux_type = other$type,
          aux_loc = .province(other$loc), aux_target = NA_character_,
          via_convoy = FALSE
        )
      }
      movers <- all_units[.province(all_units$loc) != .province(u$loc), ,
                          drop = FALSE]
      if (nrow(movers) > 0L) {
        can <- vapply(
          seq_len(nrow(movers)),
          function(j) {
            .can_step(map, movers$type[j], movers$loc[j], d) ||
              (movers$type[j] == "army" &&
                 .province(d) %in% conv_to(.province(movers$loc[j])))
          },
          logical(1)
        )
        src <- movers[can, , drop = FALSE]
        if (nrow(src) > 0L) {
          out[[length(out) + 1L]] <- tibble::tibble(
            power = u$power, type = "support", unit_type = u$type,
            loc = u$loc, target = NA_character_, aux_type = src$type,
            aux_loc = .province(src$loc), aux_target = .province(d),
            via_convoy = FALSE
          )
        }
      }
    }
    # Convoys.
    if (u$type == "fleet" && .province_type(map, u$loc) == "sea") {
      armies <- all_units[all_units$type == "army", , drop = FALSE]
      if (nrow(armies) > 0L) {
        for (j in seq_len(nrow(armies))) {
          from <- .province(armies$loc[j])
          tos <- .convoy_reachable(game, from, must_use = .province(u$loc))
          tos <- setdiff(tos, from)
          if (length(tos) > 0L) {
            out[[length(out) + 1L]] <- tibble::tibble(
              power = u$power, type = "convoy", unit_type = "fleet",
              loc = u$loc, target = NA_character_, aux_type = "army",
              aux_loc = from, aux_target = tos, via_convoy = FALSE
            )
          }
        }
      }
    }
  }
  res <- do.call(rbind, out)
  new_dp_orders(unique(res))
}

#' @noRd
.legal_retreat_orders <- function(game, power = NULL, unit = NULL) {
  d <- game$dislodged
  if (!is.null(power)) d <- d[d$power %in% power, , drop = FALSE]
  if (!is.null(unit)) {
    d <- d[.province(d$loc) %in% .province(tolower(unit)), , drop = FALSE]
  }
  if (nrow(d) == 0L) return(.empty_orders())
  out <- vector("list", 0L)
  for (i in seq_len(nrow(d))) {
    dest <- .retreat_options(game, d[i, ])
    out[[length(out) + 1L]] <- tibble::tibble(
      power = d$power[i], type = "disband", unit_type = d$type[i],
      loc = d$loc[i], target = NA_character_, aux_type = NA_character_,
      aux_loc = NA_character_, aux_target = NA_character_, via_convoy = FALSE
    )
    if (length(dest) > 0L) {
      out[[length(out) + 1L]] <- tibble::tibble(
        power = d$power[i], type = "retreat", unit_type = d$type[i],
        loc = d$loc[i], target = dest, aux_type = NA_character_,
        aux_loc = NA_character_, aux_target = NA_character_, via_convoy = FALSE
      )
    }
  }
  new_dp_orders(do.call(rbind, out))
}

#' @noRd
.legal_build_orders <- function(game, power = NULL) {
  powers <- power %||% game$powers
  out <- vector("list", 0L)
  for (pw in powers) {
    delta <- .build_delta(game, pw)
    if (delta > 0L) {
      sites <- .build_sites(game, pw)
      for (s in sites) {
        types <- if (.province_type(game$map, s) == "land") "army" else
          c("army", "fleet")
        for (ty in types) {
          locs <- if (ty == "fleet") {
            cs <- .coasts_of(game$map, s)
            if (length(cs) > 0L) cs else s
          } else {
            s
          }
          out[[length(out) + 1L]] <- tibble::tibble(
            power = pw, type = "build", unit_type = ty, loc = locs,
            target = NA_character_, aux_type = NA_character_,
            aux_loc = NA_character_, aux_target = NA_character_,
            via_convoy = FALSE
          )
        }
      }
      out[[length(out) + 1L]] <- tibble::tibble(
        power = pw, type = "waive", unit_type = NA_character_,
        loc = NA_character_, target = NA_character_, aux_type = NA_character_,
        aux_loc = NA_character_, aux_target = NA_character_, via_convoy = FALSE
      )
    } else if (delta < 0L) {
      own <- game$units[game$units$power == pw, , drop = FALSE]
      if (nrow(own) > 0L) {
        out[[length(out) + 1L]] <- tibble::tibble(
          power = pw, type = "disband", unit_type = own$type, loc = own$loc,
          target = NA_character_, aux_type = NA_character_,
          aux_loc = NA_character_, aux_target = NA_character_,
          via_convoy = FALSE
        )
      }
    }
  }
  if (length(out) == 0L) return(.empty_orders())
  new_dp_orders(unique(do.call(rbind, out)))
}
