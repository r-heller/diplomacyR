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
  won <- sim$games$winner
  n_games <- length(unique(sim$centres$game))
  sim$centres |>
    dplyr::group_by(.data$power) |>
    dplyr::summarise(
      games = n_games,
      survival_rate = mean(.data$centres > 0L | .data$units > 0L),
      mean_centres = mean(.data$centres),
      max_centres = max(.data$centres),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      solos = vapply(.data$power, function(p) sum(!is.na(won) & won == p),
                     integer(1)),
      win_rate = .data$solos / .data$games
    ) |>
    dplyr::select(
      "power", "games", "solos", "win_rate", "survival_rate", "mean_centres",
      "max_centres"
    ) |>
    dplyr::arrange(dplyr::desc(.data$win_rate),
                   dplyr::desc(.data$mean_centres), .data$power)
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
  tab |>
    dplyr::group_by(.data$power) |>
    dplyr::summarise(
      turns = dplyr::n(),
      start_centres = dplyr::first(.data$centres),
      final_centres = dplyr::last(.data$centres),
      peak_centres = max(.data$centres),
      mean_centres = mean(.data$centres),
      .groups = "drop"
    ) |>
    dplyr::arrange(dplyr::desc(.data$final_centres), .data$power)
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
#' @param wide Return one column per power instead of one row per power.
#'   Default `FALSE`.
#' @param powers Powers to include as columns when `wide = TRUE`. Defaults to
#'   the seven Great Powers, so the shape of the result does not depend on who
#'   happens to have survived.
#' @return A tibble taken at the movement phases only. In long form the columns
#'   are `turn`, `season`, `year`, `power` and `centres`; in wide form they are
#'   `turn`, `season`, `year` and one integer column per power.
#' @export
#' @family analysis
#' @examples
#' h <- dp_play(bots = "hold", max_years = 2)
#' dp_sc_trajectory(h)
#' dp_sc_trajectory(h, wide = TRUE)
dp_sc_trajectory <- function(history, wide = FALSE, powers = .dp_powers()) {
  .check_class(history, "dp_history")
  .check_flag(wide)
  long <- tibble::tibble(
    turn = integer(0), season = character(0), year = integer(0),
    power = character(0), centres = integer(0)
  )
  tab <- as_tibble(history)
  if (nrow(tab) > 0L) {
    tab <- tab[tab$phase == "movement", , drop = FALSE]
    long <- tab[, c("turn", "season", "year", "power", "centres"),
                drop = FALSE]
  }
  if (!wide) return(long)

  blank <- tibble::tibble(turn = integer(0), season = character(0),
                          year = integer(0))
  for (p in powers) blank[[p]] <- integer(0)
  if (nrow(long) == 0L) return(blank)

  out <- long |>
    tidyr::pivot_wider(
      id_cols = c("turn", "season", "year"),
      names_from = "power", values_from = "centres", values_fill = 0L
    )
  missing <- setdiff(powers, names(out))
  for (p in missing) out[[p]] <- 0L
  out[, c("turn", "season", "year", powers), drop = FALSE]
}
