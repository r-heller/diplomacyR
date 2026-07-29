# Analysis ---------------------------------------------------------------------

#' Summarise a batch of simulated games
#'
#' @param sim A [dp_sim] object.
#' @param what Which table to return:
#'   * `"power"` -- one row per power: games played, solo wins, win rate,
#'     survival rate and mean final centre count.
#'   * `"outcome"` -- one row per outcome type with its share.
#'   * `"length"` -- the distribution of game lengths in years.
#' @return A tibble with stable columns, empty when the simulation is empty.
#' @export
#' @family simulation
#' @examples
#' sim <- dp_simulate(n = 2, bots = "hold", max_years = 2, verbose = FALSE)
#' dp_stats(sim)
#' dp_stats(sim, "outcome")
dp_stats <- function(sim, what = c("power", "outcome", "length")) {
  .check_class(sim, "dp_sim")
  what <- rlang::arg_match(what)
  switch(what,
    power = .stats_power(sim),
    outcome = .stats_outcome(sim),
    length = .stats_length(sim)
  )
}

#' @noRd
.stats_power <- function(sim) {
  empty <- tibble::tibble(
    power = character(0), games = integer(0), solos = integer(0),
    win_rate = numeric(0), survival_rate = numeric(0),
    mean_centres = numeric(0), max_centres = integer(0)
  )
  if (nrow(sim$centres) == 0L) return(empty)
  cent <- sim$centres
  won <- sim$games$winner
  powers <- sort(unique(cent$power))
  n_games <- length(unique(cent$game))
  out <- lapply(powers, function(p) {
    rows <- cent[cent$power == p, , drop = FALSE]
    tibble::tibble(
      power = p,
      games = n_games,
      solos = sum(!is.na(won) & won == p),
      win_rate = sum(!is.na(won) & won == p) / n_games,
      survival_rate = mean(rows$centres > 0L | rows$units > 0L),
      mean_centres = mean(rows$centres),
      max_centres = max(rows$centres)
    )
  })
  out <- do.call(rbind, out)
  out[order(-out$win_rate, -out$mean_centres, out$power), , drop = FALSE]
}

#' @noRd
.stats_outcome <- function(sim) {
  empty <- tibble::tibble(
    outcome = character(0), games = integer(0), share = numeric(0)
  )
  if (nrow(sim$games) == 0L) return(empty)
  tab <- table(sim$games$outcome)
  tibble::tibble(
    outcome = names(tab),
    games = as.integer(tab),
    share = as.numeric(tab) / nrow(sim$games)
  )
}

#' @noRd
.stats_length <- function(sim) {
  empty <- tibble::tibble(
    years = integer(0), games = integer(0), share = numeric(0)
  )
  if (nrow(sim$games) == 0L) return(empty)
  tab <- table(sim$games$years)
  tibble::tibble(
    years = as.integer(names(tab)),
    games = as.integer(tab),
    share = as.numeric(tab) / nrow(sim$games)
  )
}

#' Summarise the powers of a game, a history or a simulation
#'
#' @param x A [dp_game], [dp_history] or [dp_sim] object.
#' @param ... Passed to methods.
#' @return A tibble with one row per power.
#' @export
#' @family analysis
#' @examples
#' dp_power_summary(dp_new_game())
dp_power_summary <- function(x, ...) {
  UseMethod("dp_power_summary")
}

#' @rdname dp_power_summary
#' @export
dp_power_summary.dp_game <- function(x, ...) {
  rlang::check_dots_empty()
  out <- dp_power_counts(x)
  out$home_centres <- vapply(
    out$power, function(p) length(x$map$home_centres[[p]] %||% character(0)),
    integer(1)
  )
  out$status <- ifelse(out$centres == 0L & out$units == 0L, "eliminated",
                       ifelse(out$centres >= 18L, "solo", "playing"))
  out
}

#' @rdname dp_power_summary
#' @export
dp_power_summary.dp_history <- function(x, ...) {
  rlang::check_dots_empty()
  tab <- as_tibble(x)
  if (nrow(tab) == 0L) {
    return(tibble::tibble(
      power = character(0), turns = integer(0), start_centres = integer(0),
      final_centres = integer(0), peak_centres = integer(0),
      mean_centres = numeric(0)
    ))
  }
  powers <- sort(unique(tab$power))
  out <- lapply(powers, function(p) {
    rows <- tab[tab$power == p, , drop = FALSE]
    tibble::tibble(
      power = p,
      turns = nrow(rows),
      start_centres = rows$centres[1],
      final_centres = rows$centres[nrow(rows)],
      peak_centres = max(rows$centres),
      mean_centres = mean(rows$centres)
    )
  })
  out <- do.call(rbind, out)
  out[order(-out$final_centres, out$power), , drop = FALSE]
}

#' @rdname dp_power_summary
#' @export
dp_power_summary.dp_sim <- function(x, ...) {
  rlang::check_dots_empty()
  dp_stats(x, "power")
}

#' Supply-centre trajectories from a game history
#'
#' @param history A [dp_history] object.
#' @return A tibble with columns `turn`, `season`, `year`, `power` and
#'   `centres`, taken at the movement phases only.
#' @export
#' @family analysis
#' @examples
#' h <- dp_play(bots = "hold", max_years = 2)
#' dp_sc_trajectory(h)
dp_sc_trajectory <- function(history) {
  .check_class(history, "dp_history")
  tab <- as_tibble(history)
  if (nrow(tab) == 0L) {
    return(tibble::tibble(
      turn = integer(0), season = character(0), year = integer(0),
      power = character(0), centres = integer(0)
    ))
  }
  tab <- tab[tab$phase == "movement", , drop = FALSE]
  tab[, c("turn", "season", "year", "power", "centres"), drop = FALSE]
}
