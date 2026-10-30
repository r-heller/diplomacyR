# Loop drivers -----------------------------------------------------------------

#' Resolve one phase and advance the game
#'
#' Adjudicates the current phase -- movement, retreat or adjustment -- and
#' returns the next game state. Any power without orders is played by `bots`.
#'
#' @param game A [dp_game] object.
#' @param orders Orders for this phase, as a `dp_orders` tibble or a character
#'   vector. `NULL` lets the bots order every power.
#' @param bots Bot assignment for powers with no orders: a single bot name or
#'   a named character vector. See [dp_ai_orders()].
#' @param call Caller environment, for error reporting. Experts only.
#' @return The next [dp_game] state. The result that produced it is stored in
#'   the `last_result` element.
#' @export
#' @family engine
#' @examples
#' g <- dp_new_game()
#' g2 <- dp_step(g, bots = "hold")
#' g2$season
dp_step <- function(game, orders = NULL, bots = "greedy",
                    call = rlang::caller_env()) {
  .check_game(game, call = call)
  orders <- .as_orders(orders, game, call = call)
  ordered_powers <- unique(orders$power)
  missing_powers <- setdiff(game$powers, ordered_powers)
  if (length(missing_powers) > 0L) {
    spec <- .expand_bots(bots, game$powers, call = call)
    extra <- lapply(missing_powers, function(p) {
      dp_ai_orders(game, p, spec[[p]])
    })
    orders <- do.call(dp_bind_orders, c(list(orders), extra))
  }
  result <- switch(game$phase,
    movement = dp_adjudicate(game, orders, call = call),
    retreat = dp_retreat(game, orders, call = call),
    build = dp_build(game, orders, call = call)
  )
  out <- dp_advance(game, result, call = call)
  out$last_result <- result
  out$last_orders <- orders
  out
}

#' Play a game to completion
#'
#' Steps the game until a power controls 18 supply centres or the turn cap is
#' reached, recording every turn.
#'
#' @param game A [dp_game] object to start from. Defaults to a new game.
#' @param bots Bot assignment: a single bot name or a named character vector
#'   mapping power to bot.
#' @param max_years Stop after this many game years. Default `20`.
#' @param seed Optional finite integer RNG seed. Restores the caller's random
#'   state afterwards, including on failure.
#' @param verbose Report each year as it is played. Default `FALSE`.
#' @param call Caller environment, for error reporting. Experts only.
#' @return A [dp_history] object. The final state is in its last turn, and the
#'   outcome is on the history's `outcome` element.
#' @export
#' @family engine
#' @examples
#' h <- dp_play(bots = "hold", max_years = 2)
#' as_tibble(h)
dp_play <- function(game = dp_new_game(), bots = "greedy", max_years = 20,
                    seed = NULL, verbose = FALSE,
                    call = rlang::caller_env()) {
  .check_game(game, call = call)
  max_years <- .check_count(max_years, min = 1L, call = call)
  .check_flag(verbose, call = call)
  if (!is.null(seed)) {
    seed <- .check_count(seed, min = -.Machine$integer.max, call = call)
    old_seed <- get0(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    on.exit(.restore_seed(old_seed), add = TRUE)
    set.seed(seed)
  }

  history <- dp_history()
  last_year <- as.double(game$year) + max_years - 1
  if (last_year >= .Machine$integer.max)
    cli::cli_abort("The requested year range exceeds the integer year limit.", call = call)
  guard <- 0L
  while (game$year <= last_year && !isTRUE(game$status$over) &&
         guard < 40 * max_years) {
    guard <- guard + 1L
    before <- game
    game <- dp_step(game, orders = NULL, bots = bots, call = call)
    history <- dp_history_append(history, before, game$last_orders,
                                 game$last_result)
    if (verbose && game$phase == "movement" && game$season == "Spring") {
      cli::cli_alert_info("Reached {game$season} {game$year}.")
    }
  }
  vc <- dp_victory_check(game)
  history$final <- game
  history$outcome <- if (isTRUE(vc$over)) vc$outcome else "draw"
  history$winner <- vc$winner
  history$years <- game$year - (last_year - max_years + 1L)
  validate_dp_history(history, call = call)
}
