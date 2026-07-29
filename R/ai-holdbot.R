# Hold bot ---------------------------------------------------------------------

#' Hold everything
#'
#' The most passive legal player: every unit holds. Forced to act, it retreats
#' to the first open province, builds armies at home, and lets the
#' civil-disorder rule choose its disbands.
#'
#' @param game A [dp_game] object.
#' @param power The power to order.
#' @param legal Legal orders for that power.
#' @param ... Ignored.
#' @return A `dp_orders` tibble.
#' @noRd
.ai_hold <- function(game, power, legal, ...) {
  score <- switch(game$phase,
    movement = ifelse(legal$type == "hold", 1, 0),
    retreat = ifelse(legal$type == "retreat", 1, 0),
    build = rep(0, nrow(legal))
  )
  if (game$phase == "build") {
    delta <- .build_delta(game, power)
    if (delta > 0L) {
      cand <- legal[legal$type == "build" & legal$unit_type == "army", ,
                    drop = FALSE]
      cand <- cand[!duplicated(.province(cand$loc)), , drop = FALSE]
      return(new_dp_orders(utils::head(cand, delta)))
    }
    return(.empty_orders())
  }
  .pick_best(legal, score)
}
