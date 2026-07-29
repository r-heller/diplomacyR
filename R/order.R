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
#' @return `x`, validated.
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
  x
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
    cli::cli_abort("Unknown province {.val {(.province(loc))}}.", call = call)
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
  } else if (!is.na(loc)) {
    # An inland province can only hold an army and a sea province only a
    # fleet; a coastal province stays ambiguous until the board says.
    ptype <- .province_type(map, loc)
    ut <- switch(ptype, land = "army", sea = "fleet", NA_character_)
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

#' Assemble an orders tibble from accumulated column chunks
#'
#' Building one tibble per candidate order is far too slow for the order
#' enumerator, so chunks of columns are collected and bound once.
#'
#' @param chunks A list of named lists of equal-length vectors.
#' @return A `dp_orders` tibble.
#' @noRd
.orders_from_chunks <- function(chunks) {
  if (length(chunks) == 0L) return(.empty_orders())
  nms <- names(.empty_orders())
  cols <- lapply(nms, function(cn) {
    unlist(lapply(chunks, function(ch) ch[[cn]]), use.names = FALSE)
  })
  names(cols) <- nms
  n <- length(cols$type)
  if (n == 0L) return(.empty_orders())
  new_dp_orders(tibble::new_tibble(cols, nrow = n))
}

#' @noRd
.order_chunk <- function(power, type, unit_type, loc, target = NA_character_,
                         aux_type = NA_character_, aux_loc = NA_character_,
                         aux_target = NA_character_, via_convoy = FALSE) {
  n <- max(lengths(list(target, aux_type, aux_loc, aux_target)), 1L)
  list(
    power = rep_len(power, n), type = rep_len(type, n),
    unit_type = rep_len(unit_type, n), loc = rep_len(loc, n),
    target = rep_len(target, n), aux_type = rep_len(aux_type, n),
    aux_loc = rep_len(aux_loc, n), aux_target = rep_len(aux_target, n),
    via_convoy = rep_len(via_convoy, n)
  )
}

#' @noRd
.legal_movement_orders <- function(game, power = NULL, unit = NULL) {
  map <- game$map
  all_units <- game$units
  if (nrow(all_units) == 0L) return(.empty_orders())

  reach <- .convoy_reach_table(game)
  n <- nrow(all_units)
  # Where each unit on the board could step, as full locations and as
  # provinces. Building this once turns the support enumeration below into a
  # lookup instead of a scan over every unit.
  step_locs <- vector("list", n)
  conv_locs <- vector("list", n)
  for (j in seq_len(n)) {
    prov <- .province(all_units$loc[j])
    if (all_units$type[j] == "army") {
      step_locs[[j]] <- map$army_adj[[prov]] %||% character(0)
      conv_locs[[j]] <- setdiff(reach[[prov]] %||% character(0),
                                c(step_locs[[j]], prov))
    } else {
      step_locs[[j]] <- .fleet_moves(map, all_units$loc[j])
      conv_locs[[j]] <- character(0)
    }
  }
  targets <- lapply(seq_len(n), function(j) {
    unique(.province(c(step_locs[[j]], conv_locs[[j]])))
  })
  movers_to <- split(rep(seq_len(n), lengths(targets)),
                     unlist(targets, use.names = FALSE))

  keep <- seq_len(n)
  if (!is.null(power)) keep <- keep[all_units$power[keep] %in% power]
  if (!is.null(unit)) {
    keep <- keep[.province(all_units$loc[keep]) %in% .province(tolower(unit))]
  }
  if (length(keep) == 0L) return(.empty_orders())

  chunks <- vector("list", 0L)
  add <- function(...) chunks[[length(chunks) + 1L]] <<- .order_chunk(...)

  for (i in keep) {
    pw <- all_units$power[i]
    ut <- all_units$type[i]
    loc <- all_units$loc[i]
    prov <- .province(loc)
    add(pw, "hold", ut, loc)
    if (length(step_locs[[i]]) > 0L) {
      add(pw, "move", ut, loc, target = step_locs[[i]])
    }
    if (length(conv_locs[[i]]) > 0L) {
      add(pw, "move", ut, loc, target = conv_locs[[i]], via_convoy = TRUE)
    }
    for (d in unique(.province(step_locs[[i]]))) {
      here <- .unit_index(all_units, d)
      if (!is.na(here) && here != i) {
        add(pw, "support", ut, loc, aux_type = all_units$type[here],
            aux_loc = d)
      }
      src <- setdiff(movers_to[[d]] %||% integer(0), i)
      if (length(src) > 0L) {
        add(pw, "support", ut, loc, aux_type = all_units$type[src],
            aux_loc = .province(all_units$loc[src]), aux_target = d)
      }
    }
    if (ut == "fleet" && .province_type(map, loc) == "sea") {
      for (j in which(all_units$type == "army")) {
        from <- .province(all_units$loc[j])
        tos <- setdiff(.convoy_reachable(game, from, must_use = prov), from)
        if (length(tos) > 0L) {
          add(pw, "convoy", "fleet", loc, aux_type = "army", aux_loc = from,
              aux_target = tos)
        }
      }
    }
  }
  out <- .orders_from_chunks(chunks)
  new_dp_orders(unique(out))
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
