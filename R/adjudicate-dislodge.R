# Strengths, standoffs and dislodgement ----------------------------------------
#
# The four strengths below follow the standard formulation of the rules:
#
# * hold strength    -- how hard a province is to take.
# * attack strength  -- how hard a move pushes, discounting support that would
#                       dislodge a unit of the attacker's own power.
# * defend strength  -- how hard the far side of a head-to-head battle pushes
#                       back.
# * prevent strength -- how hard a move stops *other* moves into the same
#                       province, even when it fails itself.
#
# A move succeeds only when its attack strength strictly exceeds the relevant
# opposition; ties bounce. That single rule produces standoffs, beleaguered
# garrisons, and the prohibitions on self-dislodgement and self-standoff.

#' The opposing move in a head-to-head battle, if any
#'
#' Two units swap places without a fight when at least one of them is
#' convoyed, so a head-to-head battle needs both moves to be overland.
#'
#' @param st Resolver state environment.
#' @param i Index of a move order.
#' @return The index of the opposing move, or `NA_integer_`.
#' @noRd
.head_to_head <- function(st, i) {
  ord <- st$orders
  src <- .province(ord$loc[i])
  dst <- .province(ord$target[i])
  j <- st$order_at[[dst]] %||% NA_integer_
  if (is.na(j)) return(NA_integer_)
  if (ord$type[j] != "move") return(NA_integer_)
  if (.province(ord$target[j]) != src) return(NA_integer_)
  if (st$is_convoy[i] || st$is_convoy[j]) return(NA_integer_)
  j
}

#' Hold strength of a province
#'
#' @param st Resolver state environment.
#' @param prov Province code.
#' @return A non-negative integer.
#' @noRd
.hold_strength <- function(st, prov) {
  i <- st$order_at[[prov]] %||% NA_integer_
  if (is.na(i)) return(0L)
  if (st$orders$type[i] == "move") {
    return(if (.resolve(st, i)) 0L else 1L)
  }
  1L + length(.supports_for_hold(st, prov))
}

#' Attack strength of a move
#'
#' @param st Resolver state environment.
#' @param i Index of the move order.
#' @return A non-negative integer.
#' @noRd
.attack_strength <- function(st, i) {
  if (!.path_successful(st, i)) return(0L)
  ord <- st$orders
  dst <- .province(ord$target[i])
  sup <- .supports_for_move(st, i)
  occ <- st$order_at[[dst]] %||% NA_integer_
  if (is.na(occ)) return(1L + length(sup))
  hth <- .head_to_head(st, i)
  if (is.na(hth) && ord$type[occ] == "move" && .resolve(st, occ)) {
    return(1L + length(sup))
  }
  if (ord$power[occ] == ord$power[i]) return(0L)
  if (length(sup) > 0L) sup <- sup[ord$power[sup] != ord$power[occ]]
  1L + length(sup)
}

#' Defend strength of a move in a head-to-head battle
#'
#' @param st Resolver state environment.
#' @param i Index of the move order.
#' @return A positive integer.
#' @noRd
.defend_strength <- function(st, i) {
  1L + length(.supports_for_move(st, i))
}

#' Prevent strength of a move
#'
#' @param st Resolver state environment.
#' @param i Index of the move order.
#' @return A non-negative integer.
#' @noRd
.prevent_strength <- function(st, i) {
  if (!.path_successful(st, i)) return(0L)
  hth <- .head_to_head(st, i)
  if (!is.na(hth) && .resolve(st, hth)) return(0L)
  1L + length(.supports_for_move(st, i))
}

#' Adjudicate a move order
#'
#' @param st Resolver state environment.
#' @param i Index of the move order.
#' @return `TRUE` when the unit reaches its destination.
#' @noRd
.adjudicate_move <- function(st, i) {
  if (!.path_successful(st, i)) return(FALSE)
  dst <- .province(st$orders$target[i])
  att <- .attack_strength(st, i)
  if (att == 0L) return(FALSE)
  hth <- .head_to_head(st, i)
  if (!is.na(hth)) {
    if (att <= .defend_strength(st, hth)) return(FALSE)
  } else {
    if (att <= .hold_strength(st, dst)) return(FALSE)
  }
  for (k in st$moves_into[[dst]] %||% integer(0)) {
    if (k == i) next
    if (att <= .prevent_strength(st, k)) return(FALSE)
  }
  TRUE
}

#' Collect dislodgements and standoffs once every order is resolved
#'
#' @param st Resolver state environment.
#' @return A list with `units`, `dislodged` and `contested`.
#' @noRd
.collect_outcome <- function(st) {
  ord <- st$orders
  units <- st$units
  success <- st$result

  moved <- which(ord$type == "move" & success)
  new_loc <- units$loc
  for (i in moved) new_loc[i] <- ord$target[i]

  dislodged_idx <- integer(0)
  from <- character(0)
  by_convoy <- logical(0)
  for (p in names(st$order_at)) {
    i <- st$order_at[[p]]
    if (ord$type[i] == "move" && success[i]) next
    winners <- Filter(function(j) success[j], st$moves_into[[p]] %||% integer(0))
    if (length(winners) == 1L) {
      dislodged_idx <- c(dislodged_idx, i)
      from <- c(from, .province(ord$loc[winners[[1]]]))
      by_convoy <- c(by_convoy, st$is_convoy[winners[[1]]])
    }
  }

  contested <- character(0)
  for (p in names(st$moves_into)) {
    idx <- st$moves_into[[p]]
    if (length(idx) >= 2L && !any(success[idx])) contested <- c(contested, p)
  }

  keep <- setdiff(seq_len(nrow(units)), dislodged_idx)
  out_units <- tibble::tibble(
    power = units$power[keep],
    type = units$type[keep],
    loc = new_loc[keep]
  )
  out_dislodged <- tibble::tibble(
    power = units$power[dislodged_idx],
    type = units$type[dislodged_idx],
    loc = units$loc[dislodged_idx],
    from = from,
    by_convoy = by_convoy
  )
  list(units = out_units, dislodged = out_dislodged,
       contested = sort(unique(contested)))
}
