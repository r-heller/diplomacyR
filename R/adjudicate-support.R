# Support ---------------------------------------------------------------------
#
# Support is the only way a unit gains strength, and cutting it is the only way
# to take that strength away. A support order is cut when an enemy unit is
# ordered to move into the supporting unit's province, unless the attack comes
# from the very province the support is directed into -- in which case only an
# actual dislodgement removes the support.

#' Indices of the support orders backing a move
#'
#' Support is given at province level: a support directed into Spain backs a
#' move into either Spanish coast.
#'
#' @param st Resolver state environment.
#' @param i Index of the move order being supported.
#' @return An integer vector of support-order indices whose support is given.
#' @noRd
.supports_for_move <- function(st, i) {
  cand <- st$support_move[[paste0(.province(st$orders$loc[i]), ">",
                                  .province(st$orders$target[i]))]]
  if (is.null(cand) || length(cand) == 0L) return(integer(0))
  cand[vapply(cand, function(j) .resolve(st, j), logical(1))]
}

#' Indices of the support orders holding a province
#'
#' @param st Resolver state environment.
#' @param prov Province code of the supported unit.
#' @return An integer vector of support-order indices whose support is given.
#' @noRd
.supports_for_hold <- function(st, prov) {
  cand <- st$support_hold[[prov]]
  if (is.null(cand) || length(cand) == 0L) return(integer(0))
  cand[vapply(cand, function(j) .resolve(st, j), logical(1))]
}

#' Adjudicate a support order
#'
#' @param st Resolver state environment.
#' @param i Index of the support order.
#' @return `TRUE` when the support is given.
#' @noRd
.adjudicate_support <- function(st, i) {
  ord <- st$orders
  prov <- .province(ord$loc[i])
  directed <- if (is.na(ord$aux_target[i])) {
    .province(ord$aux_loc[i])
  } else {
    .province(ord$aux_target[i])
  }
  attackers <- st$moves_into[[prov]] %||% integer(0)
  for (j in attackers) {
    if (ord$power[j] == ord$power[i]) next
    src <- .province(ord$loc[j])
    if (identical(src, directed)) {
      # An attack out of the province the support is aimed at cuts the
      # support only by dislodging the supporting unit.
      if (.resolve(st, j)) return(FALSE)
      next
    }
    if (.path_successful(st, j)) return(FALSE)
  }
  TRUE
}
