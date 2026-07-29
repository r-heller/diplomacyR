# Negotiator bot ---------------------------------------------------------------
#
# Experimental. Diplomacy is a negotiation game and this package has no
# negotiation protocol, so the bot substitutes a crude standing: it treats the
# board leader as the common enemy and the weakest neighbour as an ally worth
# leaving alone. That is enough to stop the greedy bots from all piling onto
# the same victim, and no more than that.

#' Greedy play with a crude threat model
#'
#' @param game A [dp_game] object.
#' @param power The power to order.
#' @param legal Legal orders for that power.
#' @param ... Ignored.
#' @return A `dp_orders` tibble.
#' @noRd
.ai_negotiator <- function(game, power, legal, ...) {
  if (game$phase != "movement") return(.ai_greedy(game, power, legal))
  counts <- dp_power_counts(game)
  counts <- counts[counts$power != power, , drop = FALSE]
  if (nrow(counts) == 0L) return(.ai_greedy(game, power, legal))
  hostile <- counts$power[counts$centres == max(counts$centres)]
  friendly <- counts$power[counts$centres == min(counts$centres)]
  hostile <- setdiff(hostile, friendly)
  .greedy_movement(game, power, legal, hostile = hostile)
}
