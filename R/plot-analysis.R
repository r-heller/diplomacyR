# Simulation dashboards --------------------------------------------------------

#' Chart win rates by power
#'
#' @param sim A [dp_sim] object.
#' @return A \pkg{ggplot2} object.
#' @export
#' @family plot
#' @examples
#' sim <- dp_simulate(n = 2, bots = "hold", max_years = 2, verbose = FALSE)
#' dp_plot_winrates(sim)
dp_plot_winrates <- function(sim) {
  .check_class(sim, "dp_sim")
  dat <- dp_stats(sim, "power")
  ggplot2::ggplot(
    dat,
    ggplot2::aes(x = stats::reorder(.data$power, .data$win_rate),
                 y = .data$win_rate, fill = .data$power)
  ) +
    ggplot2::geom_col(width = 0.7) +
    ggplot2::coord_flip() +
    ggplot2::scale_fill_manual(values = dp_palette(), guide = "none") +
    ggplot2::scale_y_continuous(labels = function(x) paste0(100 * x, "%")) +
    ggplot2::labs(
      title = "Solo win rate by power",
      subtitle = paste0(nrow(sim$games), " simulated game",
                        if (nrow(sim$games) == 1L) "" else "s"),
      x = NULL, y = "Win rate"
    ) +
    .dp_theme()
}

#' Chart mean final supply centres by power
#'
#' @param sim A [dp_sim] object.
#' @return A \pkg{ggplot2} object.
#' @export
#' @family plot
#' @examples
#' sim <- dp_simulate(n = 2, bots = "hold", max_years = 2, verbose = FALSE)
#' dp_plot_centres(sim)
dp_plot_centres <- function(sim) {
  .check_class(sim, "dp_sim")
  dat <- sim$centres
  ggplot2::ggplot(
    dat,
    ggplot2::aes(x = .data$power, y = .data$centres, fill = .data$power)
  ) +
    ggplot2::geom_boxplot(alpha = 0.8, outlier.size = 0.8) +
    ggplot2::scale_fill_manual(values = dp_palette(), guide = "none") +
    ggplot2::labs(
      title = "Final supply-centre counts",
      subtitle = "Distribution across simulated games",
      x = NULL, y = "Supply centres"
    ) +
    .dp_theme()
}

#' Map how often each province was contested
#'
#' Draws the board with each province shaded by the number of times a standoff
#' occurred there across the simulated games.
#'
#' @param sim A [dp_sim] object.
#' @param map A [dp_map] object supplying the board coordinates.
#' @return A \pkg{ggplot2} object.
#' @export
#' @family plot
#' @examples
#' sim <- dp_simulate(n = 2, bots = "random", max_years = 2, verbose = FALSE)
#' dp_plot_supply_heatmap(sim)
dp_plot_supply_heatmap <- function(sim, map = dp_map()) {
  .check_class(sim, "dp_sim")
  .check_class(map, "dp_map")
  prov <- map$provinces
  hit <- match(prov$code, sim$contests$province)
  prov$contests <- ifelse(is.na(hit), 0L, sim$contests$contests[hit])

  ggplot2::ggplot(
    prov,
    ggplot2::aes(x = .data$x, y = .data$y, fill = .data$contests)
  ) +
    ggplot2::geom_point(shape = 21, size = 6, colour = "grey70",
                        stroke = 0.3) +
    ggplot2::geom_text(ggplot2::aes(label = .data$code), size = 1.9,
                       colour = "grey20") +
    ggplot2::scale_fill_gradient(low = "#F2EDF7", high = .dp_accent(),
                                 name = "Standoffs") +
    ggplot2::coord_equal(clip = "off") +
    ggplot2::labs(
      title = "Where the fighting happens",
      subtitle = "Standoffs per province across the simulated games",
      x = NULL, y = NULL
    ) +
    .dp_theme() +
    ggplot2::theme(
      axis.text = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    )
}
