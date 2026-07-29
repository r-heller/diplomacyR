# Bots -------------------------------------------------------------------------
#
# Every bot picks its orders out of `dp_legal_orders()`, so a bot can never
# emit an order the rules forbid. What separates them is how they score the
# candidates.

#' Generate orders for a power using a bot
#'
#' Produces a complete, legal order set for one power in the game's current
#' phase.
#'
#' @param game A [dp_game] object.
#' @param power The power to generate orders for.
#' @param bot Bot strategy:
#'   * `"random"` -- picks uniformly among that unit's legal orders.
#'   * `"hold"` -- holds everything, disbands when forced to choose.
#'   * `"greedy"` -- walks each unit towards the nearest supply centre it does
#'     not own and supports its own attacks.
#'   * `"negotiator"` -- greedy, plus a crude model of who the threat is.
#'     Experimental.
#' @param ... Passed to the individual bot.
#' @return A `dp_orders` tibble of legal orders for `power`.
#' @export
#' @family ai
#' @examples
#' g <- dp_new_game()
#' dp_ai_orders(g, "France", bot = "greedy")
dp_ai_orders <- function(game, power, bot = "greedy", ...) {
  .check_game(game)
  power <- .match_power(power, game$powers)
  bot <- rlang::arg_match(bot, c("random", "hold", "greedy", "negotiator"))
  legal <- dp_legal_orders(game, power)
  if (nrow(legal) == 0L) return(.empty_orders())
  switch(bot,
    random = .ai_random(game, power, legal, ...),
    hold = .ai_hold(game, power, legal, ...),
    greedy = .ai_greedy(game, power, legal, ...),
    negotiator = .ai_negotiator(game, power, legal, ...)
  )
}

#' Orders for every power in a game
#'
#' @param game A [dp_game] object.
#' @param bots Either one bot name for all powers, or a named character vector
#'   mapping power to bot.
#' @param call Caller environment, for error reporting. Experts only.
#' @return A `dp_orders` tibble covering every power.
#' @export
#' @family ai
#' @examples
#' g <- dp_new_game()
#' nrow(dp_ai_all(g, bots = "hold"))
dp_ai_all <- function(game, bots = "greedy", call = rlang::caller_env()) {
  .check_game(game, call = call)
  bots <- .expand_bots(bots, game$powers, call = call)
  parts <- lapply(game$powers, function(p) dp_ai_orders(game, p, bots[[p]]))
  do.call(dp_bind_orders, parts)
}

#' Normalise a bot specification
#'
#' @param bots One bot name, or a named vector of bot names.
#' @param powers Powers in the game.
#' @param call Caller environment, for error reporting.
#' @return A named character vector, one bot per power.
#' @noRd
.expand_bots <- function(bots, powers, call = rlang::caller_env()) {
  if (!is.character(bots)) {
    cli::cli_abort("{.arg bots} must be a character vector.", call = call)
  }
  if (length(bots) == 1L && is.null(names(bots))) {
    return(stats::setNames(rep(unname(bots), length(powers)), powers))
  }
  if (is.null(names(bots))) {
    if (length(bots) != length(powers)) {
      cli::cli_abort(
        "{.arg bots} must be length 1 or {length(powers)}, or be named.",
        call = call
      )
    }
    return(stats::setNames(bots, powers))
  }
  out <- stats::setNames(rep("greedy", length(powers)), powers)
  nm <- .match_power(names(bots), powers, call = call)
  out[nm] <- unname(bots)
  out
}

#' Pick one order per unit from a scored candidate set
#'
#' @param legal A `dp_orders` tibble of candidates.
#' @param score Numeric score per row; the highest wins, ties broken randomly.
#' @return A `dp_orders` tibble with one row per ordered unit.
#' @noRd
.pick_best <- function(legal, score) {
  keys <- ifelse(is.na(legal$loc), "-", legal$loc)
  jitter <- stats::runif(length(score), 0, 1e-6)
  pick <- vapply(
    split(seq_along(keys), keys),
    function(idx) idx[which.max(score[idx] + jitter[idx])],
    integer(1)
  )
  new_dp_orders(legal[sort(pick), , drop = FALSE])
}

#' Distance from a location to the nearest of a set of provinces
#'
#' @param map A [dp_map] object.
#' @param type `"army"` or `"fleet"`.
#' @param loc Starting location.
#' @param targets Character vector of province codes.
#' @param max_steps Search cut-off.
#' @return A numeric distance in moves, `Inf` when unreachable.
#' @noRd
.distance_to <- function(map, type, loc, targets, max_steps = 8L) {
  if (length(targets) == 0L) return(Inf)
  if (.province(loc) %in% targets) return(0)
  seen <- loc
  frontier <- loc
  for (d in seq_len(max_steps)) {
    nxt <- unique(unlist(lapply(frontier, function(l) {
      if (type == "army") {
        map$army_adj[[.province(l)]] %||% character(0)
      } else {
        map$fleet_adj[[l]] %||% character(0)
      }
    }), use.names = FALSE))
    nxt <- setdiff(nxt, seen)
    if (length(nxt) == 0L) return(Inf)
    if (any(.province(nxt) %in% targets)) return(d)
    seen <- c(seen, nxt)
    frontier <- nxt
  }
  Inf
}
