# Palette, terrain colours and themes ------------------------------------------

#' Colours for the seven Great Powers
#'
#' A colourblind-safe palette, keyed by power name. The same seven colours
#' identify units, supply-centre ownership and every power-coded series in the
#' analysis plots, so a colour means the same thing everywhere in the package.
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

#' Terrain fills for the board
#'
#' @return A named character vector keyed by province type.
#' @noRd
.dp_terrain <- function() {
  c(sea = "#B7D5E8", coast = "#EADCBB", land = "#D8C69C")
}

#' Ink colours used across the board
#'
#' @return A named character vector.
#' @noRd
.dp_ink <- function() {
  c(
    border   = "#FBF8F1",
    coastline = "#6E9DBC",
    outline  = "#8A8172",
    label    = "#4A443A",
    sea_label = "#3D6D8C",
    neutral  = "#FFFFFF",
    paper    = "#FDFBF6"
  )
}

#' A readable ink colour to sit on top of a fill
#'
#' Takes whichever of the dark and light inks has the better WCAG contrast
#' ratio against the fill. A luminance threshold is not good enough here: the
#' palette's mid-tone sky blue and orange both sit near any plausible cut, and
#' both are markedly more readable with dark ink than with white.
#'
#' @param fill A vector of colour strings.
#' @return A character vector of hex colours, as long as `fill`.
#' @noRd
.dp_on_colour <- function(fill) {
  dark <- "#1F1B16"
  light <- "#FFFFFF"
  lum <- .dp_luminance(fill)
  ratio <- function(a, b) (pmax(a, b) + 0.05) / (pmin(a, b) + 0.05)
  ifelse(ratio(lum, .dp_luminance(dark)) >= ratio(lum, .dp_luminance(light)),
         dark, light)
}

#' Relative luminance of a colour, per WCAG
#'
#' @param col A vector of colour strings.
#' @return A numeric vector.
#' @noRd
.dp_luminance <- function(col) {
  rgb <- grDevices::col2rgb(col) / 255
  lin <- ifelse(rgb <= 0.03928, rgb / 12.92, ((rgb + 0.055) / 1.055)^2.4)
  as.numeric(0.2126 * lin[1L, ] + 0.7152 * lin[2L, ] + 0.0722 * lin[3L, ])
}

#' Blend two colours
#'
#' @param from,to Colour strings.
#' @param weight Weight given to `to`, between 0 and 1.
#' @return A hex colour string, vectorised over `from` and `weight`.
#' @noRd
.dp_blend <- function(from, to, weight) {
  a <- grDevices::col2rgb(from)
  b <- grDevices::col2rgb(to)
  n <- max(ncol(a), ncol(b), length(weight))
  a <- a[, rep_len(seq_len(ncol(a)), n), drop = FALSE]
  b <- b[, rep_len(seq_len(ncol(b)), n), drop = FALSE]
  w <- rep_len(weight, n)
  mix <- a * rep(1 - w, each = 3L) + b * rep(w, each = 3L)
  grDevices::rgb(mix[1L, ], mix[2L, ], mix[3L, ], maxColorValue = 255)
}

#' The house theme for analysis plots
#'
#' @param base_size Base font size in points.
#' @return A \pkg{ggplot2} theme object.
#' @noRd
.dp_theme <- function(base_size = 11) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(
        face = "bold", colour = .dp_accent(), size = ggplot2::rel(1.25),
        margin = ggplot2::margin(b = 3)
      ),
      plot.subtitle = ggplot2::element_text(
        colour = "grey35", size = ggplot2::rel(0.95),
        margin = ggplot2::margin(b = 12)
      ),
      plot.caption = ggplot2::element_text(
        colour = "grey45", size = ggplot2::rel(0.8), hjust = 0,
        margin = ggplot2::margin(t = 12)
      ),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      plot.margin = ggplot2::margin(14, 16, 12, 14),
      axis.title = ggplot2::element_text(colour = "grey35",
                                         size = ggplot2::rel(0.9)),
      axis.text = ggplot2::element_text(colour = "grey35"),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(colour = "grey92",
                                               linewidth = 0.3),
      legend.title = ggplot2::element_text(face = "bold",
                                           size = ggplot2::rel(0.85)),
      legend.text = ggplot2::element_text(size = ggplot2::rel(0.85)),
      legend.key.height = ggplot2::unit(0.9, "lines"),
      legend.margin = ggplot2::margin(0, 0, 0, 0),
      strip.text = ggplot2::element_text(face = "bold", colour = "grey20")
    )
}

#' The house theme for the board
#'
#' @param base_size Base font size in points.
#' @return A \pkg{ggplot2} theme object.
#' @noRd
.dp_theme_map <- function(base_size = 11) {
  .dp_theme(base_size) +
    ggplot2::theme(
      axis.text = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(fill = .dp_ink()[["paper"]],
                                               colour = NA),
      plot.background = ggplot2::element_rect(fill = "white", colour = NA),
      legend.position = "bottom",
      legend.box = "vertical",
      legend.box.just = "left",
      legend.box.spacing = ggplot2::unit(8, "pt"),
      legend.spacing.y = ggplot2::unit(2, "pt"),
      legend.justification = "left",
      legend.key = ggplot2::element_blank(),
      legend.key.width = ggplot2::unit(1.1, "lines")
    )
}
