# Supply-centre trajectories ---------------------------------------------------

#' Chart supply-centre counts over a game
#'
#' @param history A [dp_history] object.
#' @param threshold Draw a reference line at this centre count. `NULL` omits
#'   it. Default `18`, the solo-victory mark.
#' @return A \pkg{ggplot2} object.
#' @export
#' @family plot
#' @examples
#' h <- dp_play(bots = "hold", max_years = 2)
#' dp_plot_sc_history(h)
dp_plot_sc_history <- function(history, threshold = 18) {
  .check_class(history, "dp_history")
  dat <- dp_sc_trajectory(history)
  p <- ggplot2::ggplot(
    dat,
    ggplot2::aes(x = .data$turn, y = .data$centres, colour = .data$power)
  ) +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::geom_point(size = 1.4) +
    ggplot2::scale_colour_manual(values = dp_palette(), name = "Power") +
    ggplot2::labs(
      title = "Supply centres over the game",
      subtitle = "Counted at each movement phase",
      x = "Movement phase", y = "Supply centres"
    ) +
    .dp_theme()
  if (!is.null(threshold)) {
    p <- p + ggplot2::geom_hline(
      yintercept = threshold, linetype = "dashed",
      colour = .dp_accent(), linewidth = 0.4
    )
  }
  p
}
