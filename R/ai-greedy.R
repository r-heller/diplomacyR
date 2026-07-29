# Greedy bot -------------------------------------------------------------------
#
# A serviceable opponent rather than a strong one. It walks every unit towards
# the nearest supply centre it does not already own, refuses to send two units
# to the same province, and then converts the units with nothing better to do
# into support for its own attacks.

#' Walk towards the nearest unowned centre, supporting your own attacks
#'
#' @param game A [dp_game] object.
#' @param power The power to order.
#' @param legal Legal orders for that power.
#' @param ... Ignored.
#' @return A `dp_orders` tibble.
#' @noRd
.ai_greedy <- function(game, power, legal, ...) {
  switch(game$phase,
    movement = .greedy_movement(game, power, legal),
    retreat = .greedy_retreat(game, power, legal),
    build = .greedy_build(game, power, legal)
  )
}

#' Score the movement orders available to a unit
#'
#' @param game A [dp_game] object.
#' @param power The power to order.
#' @param legal Legal orders for that power.
#' @param hostile Powers to weight attacks towards.
#' @return A numeric vector, one score per row of `legal`.
#' @noRd
.greedy_scores <- function(game, power, legal, hostile = character(0)) {
  map <- game$map
  wanted <- setdiff(map$supply_centres,
                    names(game$sc_owner)[game$sc_owner == power])
  occ_power <- game$units$power[.unit_index(game$units,
                                            .province(legal$target))]
  score <- numeric(nrow(legal))
  for (i in seq_len(nrow(legal))) {
    ty <- legal$type[i]
    if (ty == "hold") {
      own_sc <- .province(legal$loc[i]) %in% map$supply_centres &&
        identical(unname(game$sc_owner[.province(legal$loc[i])]), power)
      score[i] <- if (own_sc) 1.5 else 0.4
      next
    }
    if (ty == "move") {
      dst <- .province(legal$target[i])
      d <- .distance_to(map, legal$unit_type[i], legal$target[i], wanted)
      s <- 3 - min(d, 6)
      if (dst %in% wanted) s <- s + 3
      if (!is.na(occ_power[i])) {
        s <- if (occ_power[i] == power) s - 4 else s - 0.5
        if (!is.na(occ_power[i]) && occ_power[i] %in% hostile) s <- s + 1.5
      }
      if (isTRUE(legal$via_convoy[i])) s <- s - 1
      score[i] <- s
      next
    }
    if (ty == "support") {
      aux_idx <- .unit_index(game$units, .province(legal$aux_loc[i]))
      mine <- !is.na(aux_idx) && game$units$power[aux_idx] == power
      if (!mine) {
        score[i] <- 0.1
      } else if (is.na(legal$aux_target[i])) {
        score[i] <- 1.2
      } else {
        score[i] <- if (.province(legal$aux_target[i]) %in% wanted) 2.5 else 1.3
      }
      next
    }
    score[i] <- 0.3
  }
  score
}

#' @noRd
.greedy_movement <- function(game, power, legal, hostile = character(0)) {
  score <- .greedy_scores(game, power, legal, hostile = hostile)
  moves <- which(legal$type %in% c("move", "hold"))
  ord <- moves[order(-score[moves])]
  chosen <- integer(0)
  done <- character(0)
  claimed <- character(0)
  for (i in ord) {
    u <- legal$loc[i]
    if (u %in% done) next
    dst <- if (legal$type[i] == "move") .province(legal$target[i]) else
      .province(u)
    if (dst %in% claimed) next
    chosen <- c(chosen, i)
    done <- c(done, u)
    claimed <- c(claimed, dst)
  }
  # Units whose own move is weak switch to supporting an attack we are making.
  picked <- legal[chosen, , drop = FALSE]
  attacks <- picked[picked$type == "move", , drop = FALSE]
  if (nrow(attacks) > 0L) {
    for (k in seq_along(chosen)) {
      i <- chosen[k]
      if (legal$type[i] == "move" && score[i] >= 2) next
      cand <- which(
        legal$type == "support" & legal$loc == legal$loc[i] &
          !is.na(legal$aux_target) &
          paste(legal$aux_loc, .province(legal$aux_target)) %in%
            paste(.province(attacks$loc), .province(attacks$target))
      )
      if (length(cand) == 0L) next
      best <- cand[which.max(score[cand])]
      if (score[best] > score[i]) chosen[k] <- best
    }
  }
  new_dp_orders(legal[sort(unique(chosen)), , drop = FALSE])
}

#' @noRd
.greedy_retreat <- function(game, power, legal) {
  mine <- names(game$sc_owner)[game$sc_owner == power]
  score <- ifelse(
    legal$type == "retreat",
    1 + as.numeric(.province(legal$target) %in% mine) +
      as.numeric(.province(legal$target) %in% game$map$supply_centres) * 0.5,
    0
  )
  .pick_best(legal, score)
}

#' @noRd
.greedy_build <- function(game, power, legal) {
  delta <- .build_delta(game, power)
  if (delta > 0L) {
    cand <- legal[legal$type == "build", , drop = FALSE]
    if (nrow(cand) == 0L) return(.empty_orders())
    own <- game$units[game$units$power == power, , drop = FALSE]
    want_fleet <- sum(own$type == "fleet") < sum(own$type == "army")
    cand$rank <- ifelse(cand$unit_type == "fleet", 1L, 0L)
    if (!want_fleet) cand$rank <- 1L - cand$rank
    cand <- cand[order(-cand$rank), , drop = FALSE]
    cand <- cand[!duplicated(.province(cand$loc)), , drop = FALSE]
    cand$rank <- NULL
    return(new_dp_orders(utils::head(cand, delta)))
  }
  if (delta < 0L) {
    idx <- utils::head(.civil_disorder_order(game, power), -delta)
    if (length(idx) == 0L) return(.empty_orders())
    return(new_dp_orders(tibble::tibble(
      power = power, type = "disband",
      unit_type = game$units$type[idx], loc = game$units$loc[idx],
      target = NA_character_, aux_type = NA_character_,
      aux_loc = NA_character_, aux_target = NA_character_,
      via_convoy = FALSE
    )))
  }
  .empty_orders()
}
