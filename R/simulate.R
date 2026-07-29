# Batch simulation -------------------------------------------------------------

#' Construct a simulation result
#'
#' @param games Per-game outcome tibble.
#' @param centres Final supply-centre counts, one row per game and power.
#' @param contests Standoff counts per province.
#' @param settings The call settings.
#' @return An object of class `dp_sim`.
#' @noRd
new_dp_sim <- function(games, centres, contests, settings) {
  structure(
    list(games = games, centres = centres, contests = contests,
         settings = settings),
    class = "dp_sim"
  )
}

#' Validate a simulation result
#'
#' @param x A candidate `dp_sim`.
#' @param call Caller environment, for error reporting.
#' @return `x`, validated.
#' @noRd
validate_dp_sim <- function(x, call = rlang::caller_env()) {
  .check_class(x, "dp_sim", call = call)
  if (!all(c("game", "outcome") %in% names(x$games))) {
    cli::cli_abort("A {.cls dp_sim} must record per-game outcomes.",
                   call = call)
  }
  x
}

#' Test whether an object is a simulation result
#'
#' @param x An object to test.
#' @return A logical scalar.
#' @export
#' @family simulation
#' @examples
#' is_dp_sim(dp_simulate(n = 1, bots = "hold", max_years = 1, verbose = FALSE))
is_dp_sim <- function(x) inherits(x, "dp_sim")

#' Zero-row tibbles for a simulation
#'
#' @return A list of empty result tibbles.
#' @noRd
.empty_sim_tables <- function() {
  list(
    games = tibble::tibble(
      game = integer(0), outcome = character(0), winner = character(0),
      years = integer(0), turns = integer(0)
    ),
    centres = tibble::tibble(
      game = integer(0), power = character(0), centres = integer(0),
      units = integer(0)
    ),
    contests = tibble::tibble(
      province = character(0), contests = integer(0)
    )
  )
}

#' Simulate many Diplomacy games
#'
#' Plays `n` games to completion -- a solo victory, an elimination of all but
#' one power, or the turn cap and a draw -- with the given bot assignment, and
#' collects the outcomes.
#'
#' @param n Number of games.
#' @param bots A single bot name applied to all powers, or a named character
#'   vector mapping power to bot. See [dp_ai_orders()].
#' @param max_years Turn cap before the game is declared a draw. Default `20`.
#' @param seed Optional RNG seed for reproducibility.
#' @param verbose Report progress. Default `TRUE`.
#' @param call Caller environment, for error reporting. Experts only.
#' @return A [dp_sim] object. Summarise it with [dp_stats()] and the
#'   `dp_plot_*` functions.
#' @export
#' @family simulation
#' @examples
#' sim <- dp_simulate(n = 2, bots = "hold", max_years = 2, verbose = FALSE)
#' dp_stats(sim)
dp_simulate <- function(n = 100, bots = "greedy", max_years = 20,
                        seed = NULL, verbose = TRUE,
                        call = rlang::caller_env()) {
  n <- .check_count(n, min = 0L, call = call)
  max_years <- .check_count(max_years, min = 1L, call = call)
  .check_flag(verbose, call = call)
  if (!is.null(seed)) withr_seed(seed)

  empty <- .empty_sim_tables()
  settings <- list(n = n, bots = bots, max_years = max_years, seed = seed)
  if (n == 0L) {
    return(validate_dp_sim(new_dp_sim(empty$games, empty$centres,
                                      empty$contests, settings), call = call))
  }

  games <- vector("list", n)
  centres <- vector("list", n)
  contest_tally <- new.env(parent = emptyenv())

  for (i in seq_len(n)) {
    h <- dp_play(dp_new_game(), bots = bots, max_years = max_years,
                 verbose = FALSE, call = call)
    final <- h$final
    counts <- dp_power_counts(final)
    games[[i]] <- tibble::tibble(
      game = i,
      outcome = h$outcome %||% "draw",
      winner = h$winner %||% NA_character_,
      years = as.integer(final$year - 1900L),
      turns = length(h)
    )
    centres[[i]] <- tibble::tibble(
      game = i, power = counts$power, centres = counts$centres,
      units = counts$units
    )
    for (tn in h$turns) {
      for (p in tn$result$contested) {
        contest_tally[[p]] <- (contest_tally[[p]] %||% 0L) + 1L
      }
    }
    if (verbose) {
      cli::cli_alert_info("Game {i}/{n}: {games[[i]]$outcome}.")
    }
  }

  hit <- ls(contest_tally)
  contests <- if (length(hit) == 0L) {
    empty$contests
  } else {
    counts <- vapply(hit, function(p) contest_tally[[p]], integer(1))
    ord <- order(-counts, hit)
    tibble::tibble(
      province = hit[ord],
      contests = unname(counts[ord])
    )
  }

  validate_dp_sim(new_dp_sim(
    games = do.call(rbind, games),
    centres = do.call(rbind, centres),
    contests = contests,
    settings = settings
  ), call = call)
}
