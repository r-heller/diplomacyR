# Supply-centre trajectories ---------------------------------------------------

#' Chart supply-centre counts over a game
#'
#' One line per power against the game calendar, with the solo-victory mark
#' drawn and labelled. The final standing is written at the right-hand end of
#' each line so the powers can be told apart without reading a legend.
#'
#' Centre counts are small integers, so powers are level with each other for
#' much of a normal game. Exactly coincident lines would hide all but the last
#' power drawn, so each power's line is offset by a fraction of a centre. The
#' offsets are a fixed, tiny fraction of the axis and are noted on the plot.
#'
#' @param history A [dp_history] object.
#' @param threshold Draw a reference line at this centre count. `NULL` omits
#'   it. Default `18`, the solo-victory mark. The line is skipped, rather than
#'   stretching the axis over empty space, in a game where no power came close
#'   to it.
#' @param labels Write each power's name at the end of its line. Default
#'   `TRUE`.
#' @return A \pkg{ggplot2} object.
#' @export
#' @family plot
#' @examples
#' h <- dp_play(bots = "hold", max_years = 2)
#' dp_plot_sc_history(h)
dp_plot_sc_history <- function(history, threshold = 18, labels = TRUE) {
  .check_class(history, "dp_history")
  .check_flag(labels)
  dat <- dp_sc_trajectory(history)
  if (nrow(dat) == 0L) {
    return(.dp_empty_plot("Supply centres over the game",
                          "No movement phase has been recorded yet"))
  }
  # Place each movement phase on the game calendar: Spring on the year, Fall
  # halfway through it.
  dat$when <- dat$year + ifelse(dat$season == "Fall", 0.5, 0)
  years <- sort(unique(dat$year))
  span <- diff(range(dat$when))
  # Nudge each power off the integer, so that tied powers stay visible.
  powers <- names(dp_palette())
  nudge <- stats::setNames(
    seq(-0.16, 0.16, length.out = length(powers)), powers
  )
  dat$shown <- dat$centres + unname(nudge[dat$power])
  last <- dat[dat$when == max(dat$when), , drop = FALSE]
  last <- last[order(-last$centres, last$power), , drop = FALSE]
  # Only reserve room up to the solo mark when the game got near it; otherwise
  # the chart is mostly empty space above the data.
  near <- max(dat$centres) >= 0.6 * (threshold %||% Inf)
  mark <- if (!is.null(threshold) && near) threshold else NULL
  top <- max(c(dat$centres, mark)) + 1

  p <- ggplot2::ggplot(
    dat,
    ggplot2::aes(x = .data$when, y = .data$shown, colour = .data$power)
  )
  if (!is.null(mark)) {
    p <- p +
      ggplot2::geom_hline(yintercept = mark, linetype = "dashed",
                          colour = .dp_accent(), linewidth = 0.4) +
      ggplot2::annotate(
        "text", x = min(dat$when), y = mark, hjust = 0, vjust = -0.55,
        label = paste0("solo victory at ", mark), size = 2.9,
        colour = .dp_accent()
      )
  }
  # A history one movement phase long has a single point per power, and
  # geom_line warns that every group has one observation. Draw the points only.
  if (length(unique(dat$when)) > 1L) {
    p <- p + ggplot2::geom_line(linewidth = 0.9, alpha = 0.9)
  }
  p <- p + ggplot2::geom_point(size = 1.5)
  if (labels) {
    last$at <- .dp_spread(last$centres, top / 20)
    p <- p +
      ggplot2::geom_segment(
        data = last,
        ggplot2::aes(x = .data$when, y = .data$shown,
                     xend = .data$when + span * 0.025, yend = .data$at),
        linewidth = 0.3, alpha = 0.6, show.legend = FALSE
      ) +
      ggplot2::geom_text(
        data = last,
        ggplot2::aes(x = .data$when + span * 0.035, y = .data$at,
                     label = .data$power),
        hjust = 0, size = 2.9, fontface = "bold", show.legend = FALSE
      )
  }
  p +
    ggplot2::scale_colour_manual(values = dp_palette(), name = "Power",
                                 limits = names(dp_palette()), drop = FALSE) +
    ggplot2::scale_x_continuous(
      breaks = years, labels = years,
      expand = ggplot2::expansion(mult = c(0.02, if (labels) 0.16 else 0.02))
    ) +
    ggplot2::scale_y_continuous(limits = c(-0.3, top),
                                breaks = seq(0, 34, by = 3),
                                expand = ggplot2::expansion(c(0, 0.02))) +
    ggplot2::labs(
      title = "Supply centres over the game",
      subtitle = "Counted at every movement phase; Spring and Fall of each year",
      caption = paste("Lines are separated by a fraction of a centre where",
                      "powers are level, so that ties stay visible."),
      x = "Year", y = "Supply centres"
    ) +
    .dp_theme() +
    ggplot2::theme(
      legend.position = if (labels) "none" else "bottom",
      panel.grid.major.x = ggplot2::element_line(colour = "grey94",
                                                 linewidth = 0.3)
    )
}

#' Push overlapping label positions apart
#'
#' @param y Numeric positions.
#' @param gap Smallest separation to allow.
#' @return `y`, adjusted upward where needed, in the original order.
#' @noRd
.dp_spread <- function(y, gap) {
  if (length(y) < 2L) return(y)
  ord <- order(y)
  v <- y[ord]
  for (i in seq_along(v)[-1L]) {
    if (v[i] - v[i - 1L] < gap) v[i] <- v[i - 1L] + gap
  }
  out <- y
  out[ord] <- v
  out
}
