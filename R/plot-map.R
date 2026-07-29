# Board rendering --------------------------------------------------------------

#' Colours for the seven Great Powers
#'
#' A colourblind-safe palette, keyed by power name.
#'
#' @return A named character vector of hex colours.
#' @export
#' @family plot
#' @examples
#' dp_palette()
dp_palette <- function() {
  c(
    Austria = "#D55E00",
    England = "#0072B2",
    France  = "#56B4E9",
    Germany = "#4D4D4D",
    Italy   = "#009E73",
    Russia  = "#CC79A7",
    Turkey  = "#E69F00"
  )
}

#' The suite accent colour
#'
#' @return A single hex colour string.
#' @noRd
.dp_accent <- function() "#5E2C8E"

#' Plotting coordinates for locations
#'
#' @param map A [dp_map] object.
#' @param loc Character vector of locations, possibly coast-qualified.
#' @return A tibble with columns `loc`, `x` and `y`.
#' @noRd
.loc_xy <- function(map, loc) {
  prov <- .province(loc)
  idx <- match(prov, map$provinces$code)
  x <- map$provinces$x[idx]
  y <- map$provinces$y[idx]
  cidx <- match(loc, map$coast_xy$loc)
  has <- !is.na(cidx)
  x[has] <- map$coast_xy$x[cidx[has]]
  y[has] <- map$coast_xy$y[cidx[has]]
  tibble::tibble(loc = loc, x = x, y = y)
}

#' A minimal theme for board and analysis plots
#'
#' @return A \pkg{ggplot2} theme object.
#' @noRd
.dp_theme <- function() {
  ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold",
                                         colour = .dp_accent()),
      plot.subtitle = ggplot2::element_text(colour = "grey30"),
      legend.position = "right",
      panel.grid.minor = ggplot2::element_blank()
    )
}

#' Draw the board
#'
#' Renders a schematic map: sea provinces in blue, land in buff, supply
#' centres ringed, and every unit drawn as an `A` or `F` in its owner's
#' colour. Units awaiting a retreat are ringed in red.
#'
#' @param game A [dp_game] object.
#' @param labels Draw the three-letter province codes. Default `TRUE`.
#' @param title Plot title. `NULL` uses the current turn.
#' @return A \pkg{ggplot2} object.
#' @export
#' @family plot
#' @examples
#' dp_plot_map(dp_new_game())
dp_plot_map <- function(game, labels = TRUE, title = NULL) {
  .check_game(game)
  .check_flag(labels)
  map <- game$map
  prov <- map$provinces
  prov$fill <- ifelse(prov$type == "sea", "Sea",
                      ifelse(prov$type == "coast", "Coast", "Inland"))

  units <- game$units
  if (nrow(units) > 0L) {
    xy <- .loc_xy(map, units$loc)
    units$x <- xy$x
    units$y <- xy$y
    units$label <- .fmt_unit(units$type)
  } else {
    units$x <- numeric(0)
    units$y <- numeric(0)
    units$label <- character(0)
  }

  p <- ggplot2::ggplot() +
    ggplot2::geom_point(
      data = prov,
      ggplot2::aes(x = .data$x, y = .data$y, fill = .data$fill),
      shape = 21, size = 6, colour = "grey60", stroke = 0.3
    ) +
    ggplot2::geom_point(
      data = prov[prov$supply_centre, , drop = FALSE],
      ggplot2::aes(x = .data$x, y = .data$y),
      shape = 21, size = 9, colour = .dp_accent(), fill = NA, stroke = 0.6
    ) +
    ggplot2::scale_fill_manual(
      values = c(Sea = "#CFE3F2", Coast = "#EBDFC4", Inland = "#DCD3BC"),
      name = "Province"
    )

  if (labels) {
    p <- p + ggplot2::geom_text(
      data = prov,
      ggplot2::aes(x = .data$x, y = .data$y, label = .data$code),
      size = 1.9, colour = "grey25"
    )
  }
  if (nrow(units) > 0L) {
    p <- p + ggplot2::geom_label(
      data = units,
      ggplot2::aes(x = .data$x, y = .data$y + 1.6, label = .data$label,
                   colour = .data$power),
      size = 2.6, fill = "white", label.padding = ggplot2::unit(0.1, "lines"),
      linewidth = 0.3, show.legend = TRUE
    ) +
      ggplot2::scale_colour_manual(values = dp_palette(), name = "Power",
                                   drop = FALSE)
  }
  if (nrow(game$dislodged) > 0L) {
    dxy <- .loc_xy(map, game$dislodged$loc)
    p <- p + ggplot2::geom_point(
      data = dxy, ggplot2::aes(x = .data$x, y = .data$y),
      shape = 4, size = 4, colour = "#B2182B", stroke = 1
    )
  }

  p +
    ggplot2::coord_equal(clip = "off") +
    ggplot2::labs(
      title = title %||% paste0("Diplomacy \u2014 ", .turn_label(game)),
      subtitle = paste0(nrow(units), " units on the board"),
      x = NULL, y = NULL
    ) +
    .dp_theme() +
    ggplot2::theme(
      axis.text = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    )
}

#' @importFrom ggplot2 autoplot
#' @export
ggplot2::autoplot

#' Plot a game state
#'
#' @param object A [dp_game] object.
#' @param ... Passed to [dp_plot_map()].
#' @return A \pkg{ggplot2} object.
#' @export
#' @family plot
#' @examples
#' autoplot(dp_new_game())
autoplot.dp_game <- function(object, ...) {
  dp_plot_map(object, ...)
}
