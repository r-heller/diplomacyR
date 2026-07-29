# Legal-random bot -------------------------------------------------------------

#' Pick uniformly among the legal orders
#'
#' The baseline every other bot has to beat: for each unit, one of its legal
#' orders chosen at random. In an adjustment phase the bot builds or disbands
#' at random up to the number due.
#'
#' @param game A [dp_game] object.
#' @param power The power to order.
#' @param legal Legal orders for that power.
#' @param ... Ignored.
#' @return A `dp_orders` tibble.
#' @noRd
.ai_random <- function(game, power, legal, ...) {
  if (game$phase == "build") {
    return(.ai_random_build(game, power, legal))
  }
  .pick_best(legal, stats::runif(nrow(legal)))
}

#' @noRd
.ai_random_build <- function(game, power, legal) {
  delta <- .build_delta(game, power)
  if (delta > 0L) {
    cand <- legal[legal$type == "build", , drop = FALSE]
    if (nrow(cand) == 0L) return(.empty_orders())
    cand <- cand[sample.int(nrow(cand)), , drop = FALSE]
    cand <- cand[!duplicated(.province(cand$loc)), , drop = FALSE]
    return(new_dp_orders(utils::head(cand, delta)))
  }
  if (delta < 0L) {
    cand <- legal[legal$type == "disband", , drop = FALSE]
    if (nrow(cand) == 0L) return(.empty_orders())
    cand <- cand[sample.int(nrow(cand)), , drop = FALSE]
    return(new_dp_orders(utils::head(cand, -delta)))
  }
  .empty_orders()
}
