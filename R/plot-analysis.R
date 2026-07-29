# Simulation dashboards --------------------------------------------------------

#' Chart win rates by power
#'
#' One bar per power against a light track running the full width, so that a
#' power with no solo victories is still visible and still labelled. Each bar
#' is annotated with the underlying count.
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
  n_games <- nrow(sim$games)
  if (nrow(dat) == 0L) {
    return(.dp_empty_plot("Solo win rate by power",
                          "No games in this simulation"))
  }
  if (sum(dat$solos) == 0L) {
    # Seven bars of length zero against an arbitrary axis says nothing. Short
    # runs and passive bots end this way, so it is a common case and it should
    # look deliberate rather than broken.
    return(.dp_empty_plot(
      "Solo win rate by power",
      paste0("No power won outright in ", n_games, " game",
             if (n_games == 1L) "" else "s", ".\n",
             "Every game ended on the turn cap or in a draw.")
    ))
  }
  dat$power <- factor(dat$power,
                      levels = dat$power[order(dat$win_rate,
                                               dat$mean_centres)])
  top <- max(c(dat$win_rate, 0.08))
  dat$label <- paste0(dat$solos, " of ", dat$games)
  # The count is written inside the bar, so it needs ink chosen against the
  # bar it lands on; a fixed grey disappears on the dark grey of Germany. A
  # short bar leaves the text on the pale track instead.
  dat$ink <- ifelse(
    dat$win_rate > 0.16 * top,
    .dp_on_colour(unname(dp_palette()[as.character(dat$power)])),
    "grey25"
  )

  ggplot2::ggplot(dat, ggplot2::aes(x = .data$power, y = .data$win_rate)) +
    ggplot2::geom_col(ggplot2::aes(y = top * 1.02), fill = "grey96",
                      width = 0.72) +
    ggplot2::geom_col(ggplot2::aes(fill = .data$power), width = 0.72) +
    ggplot2::geom_text(
      ggplot2::aes(y = top * 0.015, label = .data$label),
      hjust = 0, size = 3, colour = dat$ink
    ) +
    ggplot2::coord_flip(clip = "off") +
    ggplot2::scale_fill_manual(values = dp_palette(), guide = "none") +
    ggplot2::scale_y_continuous(
      labels = function(x) paste0(round(100 * x), "%"),
      limits = c(0, top * 1.02), expand = ggplot2::expansion(0)
    ) +
    ggplot2::labs(
      title = "Solo win rate by power",
      subtitle = paste0(
        n_games, " simulated game", if (n_games == 1L) "" else "s",
        "  \u00b7  ", sum(dat$solos), " ended in a solo victory"
      ),
      x = NULL, y = "Share of games won outright"
    ) +
    .dp_theme() +
    ggplot2::theme(
      panel.grid.major.y = ggplot2::element_blank(),
      # The track sits over the vertical gridlines, so leaving them on cuts
      # each track into segments and the row reads as a dashed stripe.
      panel.grid.major.x = ggplot2::element_blank()
    )
}

#' Chart final supply centres by power
#'
#' A box for the distribution with the individual games drawn over it, so that
#' a simulation of deterministic bots -- where every game ends identically --
#' reads as a single point rather than a flat line of unclear meaning.
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
  if (nrow(dat) == 0L) {
    return(.dp_empty_plot("Final supply-centre counts",
                          "No games in this simulation"))
  }
  med <- stats::aggregate(centres ~ power, data = dat, FUN = stats::median)
  dat$power <- factor(dat$power,
                      levels = med$power[order(med$centres)])
  n_games <- length(unique(dat$game))
  spread <- if (n_games > 1L) 0.16 else 0
  # Only make room for the solo mark when a game came near it; otherwise the
  # chart is mostly empty space to the right of the data.
  near_solo <- max(dat$centres) >= 12L
  ceiling <- if (near_solo) 19 else max(dat$centres) + 1

  p <- ggplot2::ggplot(dat, ggplot2::aes(x = .data$power, y = .data$centres)) +
    ggplot2::geom_boxplot(
      ggplot2::aes(fill = .data$power), width = 0.6, alpha = 0.35,
      outlier.shape = NA, colour = "grey45", linewidth = 0.35
    ) +
    ggplot2::geom_jitter(
      ggplot2::aes(colour = .data$power), width = spread, height = 0,
      size = 1.7, alpha = 0.85
    )
  if (near_solo) {
    p <- p +
      ggplot2::geom_hline(yintercept = 18, linetype = "dashed",
                          colour = .dp_accent(), linewidth = 0.4) +
      ggplot2::annotate(
        "text", x = 0.55, y = 17.6, label = "solo at 18", hjust = 1,
        vjust = -0.3, size = 2.9, colour = .dp_accent()
      )
  }
  p +
    ggplot2::coord_flip() +
    ggplot2::scale_fill_manual(values = dp_palette(), guide = "none") +
    ggplot2::scale_colour_manual(values = dp_palette(), guide = "none") +
    ggplot2::scale_y_continuous(
      limits = c(0, ceiling),
      breaks = seq(0, 34, by = 3), expand = ggplot2::expansion(c(0, 0.02))
    ) +
    ggplot2::labs(
      title = "Final supply-centre counts",
      subtitle = paste0("Every power in every one of ", n_games,
                        " simulated game", if (n_games == 1L) "" else "s"),
      x = NULL, y = "Supply centres at the end of the game"
    ) +
    .dp_theme() +
    ggplot2::theme(panel.grid.major.y = ggplot2::element_blank())
}

#' Map how often each province was contested
#'
#' Draws the board with each province shaded by the number of times a standoff
#' occurred there across the simulated games.
#'
#' @param sim A [dp_sim] object.
#' @param map A [dp_map] object supplying the board coordinates.
#' @param labels Draw the three-letter province codes. Default `TRUE`.
#' @return A \pkg{ggplot2} object.
#' @export
#' @family plot
#' @examples
#' sim <- dp_simulate(n = 2, bots = "random", max_years = 2, verbose = FALSE)
#' dp_plot_supply_heatmap(sim)
dp_plot_supply_heatmap <- function(sim, map = dp_map(), labels = TRUE) {
  .check_class(sim, "dp_sim")
  .check_class(map, "dp_map")
  .check_flag(labels)
  geom <- .dp_board_geom(map)
  prov <- map$provinces
  hit <- match(prov$code, sim$contests$province)
  contests <- ifelse(is.na(hit), 0L, sim$contests$contests[hit])
  names(contests) <- prov$code

  cells <- geom$cells
  cells$contests <- contests[cells$code]
  anchor <- geom$anchor
  anchor$contests <- contests[anchor$code]
  top <- max(c(contests, 1L))
  anchor$dark <- anchor$contests > 0.55 * top

  ink <- .dp_ink()
  bd <- geom$borders
  p <- ggplot2::ggplot() +
    ggplot2::geom_raster(
      data = cells,
      ggplot2::aes(x = .data$x, y = .data$y, fill = .data$contests)
    ) +
    ggplot2::geom_segment(
      data = bd[bd$kind != "edge", , drop = FALSE],
      ggplot2::aes(x = .data$x, y = .data$y, xend = .data$xend,
                   yend = .data$yend),
      colour = "#CFC6DA", linewidth = 0.3
    ) +
    ggplot2::geom_segment(
      data = bd[bd$kind == "edge", , drop = FALSE],
      ggplot2::aes(x = .data$x, y = .data$y, xend = .data$xend,
                   yend = .data$yend),
      colour = ink[["outline"]], linewidth = 0.45
    )
  if (labels) {
    p <- p + ggplot2::geom_text(
      data = anchor,
      ggplot2::aes(x = .data$x, y = .data$y,
                   label = toupper(.data$code),
                   colour = .data$dark),
      size = 2.05, fontface = "bold", show.legend = FALSE
    ) +
      ggplot2::scale_colour_manual(values = c(`TRUE` = "white",
                                              `FALSE` = "grey25"))
  }
  p +
    ggplot2::scale_fill_gradientn(
      colours = c("#F1ECF6", "#DCC9EC", "#B695D6", .dp_accent(), "#2C1145"),
      limits = c(0, top), name = "Standoffs",
      guide = ggplot2::guide_colourbar(
        barwidth = ggplot2::unit(11, "lines"),
        barheight = ggplot2::unit(0.55, "lines"),
        title.position = "top", title.vjust = 1
      )
    ) +
    ggplot2::coord_equal(expand = FALSE, clip = "off") +
    ggplot2::labs(
      title = "Where the fighting happens",
      subtitle = paste0(
        "Standoffs per province across ", nrow(sim$games),
        " simulated game", if (nrow(sim$games) == 1L) "" else "s",
        if (max(contests) > 0L) {
          paste0("  \u00b7  busiest: ", toupper(names(which.max(contests))),
                 ", contested ", max(contests), " times")
        } else {
          "  \u00b7  no province was contested"
        }
      ),
      x = NULL, y = NULL
    ) +
    .dp_theme_map() +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(fill = "white", colour = NA)
    )
}

#' A titled placeholder used when there is nothing to chart
#'
#' @param title Plot title.
#' @param message Message to show in the panel.
#' @return A \pkg{ggplot2} object.
#' @noRd
.dp_empty_plot <- function(title, message) {
  ggplot2::ggplot() +
    ggplot2::annotate("text", x = 0, y = 0, label = message, size = 3.6,
                      colour = "grey40", lineheight = 1.25) +
    ggplot2::labs(title = title, x = NULL, y = NULL) +
    .dp_theme() +
    ggplot2::theme(
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      # The house theme sets `panel.grid.major` explicitly, and a blank
      # `panel.grid` does not override a more specific element, so both have to
      # be cleared by name or the placeholder keeps a full grid behind it.
      panel.grid = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank()
    )
}
