# Board rendering --------------------------------------------------------------

#' Vertical offsets of the marks drawn inside a province
#'
#' A province carries at most two rows of marks: the unit token above, the name
#' below. Provinces without a unit -- most of the board at any time -- put the
#' name on the centroid, where it is guaranteed to sit inside the territory it
#' names.
#'
#' @return A named numeric vector, in board units.
#' @noRd
.dp_offsets <- function() {
  c(unit = 1.15, label = -1.5)
}

#' Territory fill for every province of a game
#'
#' Terrain, and only terrain. Ownership used to be washed over the province fill
#' as well, and that was the board's worst reading problem: blending a power
#' colour into the land buff gives a muddy low-chroma tint, and for the two blue
#' powers it gives a pale blue indistinguishable from sea, so Brest, Paris,
#' Spain and Portugal all read as water. The two encodings are now kept apart --
#' large quiet areas carry terrain, small saturated chips carry ownership.
#'
#' @param game A [dp_game] object.
#' @return A character vector of hex colours, one per province.
#' @noRd
.dp_province_fill <- function(game) {
  unname(.dp_terrain()[game$map$provinces$type])
}

#' Fill and ink for the chip drawn on a supply centre's name
#'
#' @param game A [dp_game] object.
#' @param codes Province codes to describe.
#' @param ownership Colour the chip by owner.
#' @return A list with `fill`, `ink` and `border`, each as long as `codes`.
#' @noRd
.dp_centre_chip <- function(game, codes, ownership = TRUE) {
  pal <- dp_palette()
  owner <- if (ownership) game$sc_owner[codes] else rep(NA_character_,
                                                        length(codes))
  known <- !is.na(owner) & owner %in% names(pal)
  fill <- rep(.dp_ink()[["neutral"]], length(codes))
  fill[known] <- unname(pal[owner[known]])
  border <- rep(.dp_ink()[["outline"]], length(codes))
  border[known] <- .dp_blend(fill[known], "#000000", 0.18)
  list(fill = fill, ink = .dp_on_colour(fill), border = border)
}

#' Shrink a segment at both ends
#'
#' Keeps arrowheads clear of the tokens they point at.
#'
#' @param df A data frame with `x`, `y`, `xend`, `yend`.
#' @param start,end Distance to trim, in board units.
#' @return `df` with the coordinates moved inward.
#' @noRd
.dp_trim <- function(df, start = 1.5, end = 1.9) {
  dx <- df$xend - df$x
  dy <- df$yend - df$y
  len <- sqrt(dx^2 + dy^2)
  keep <- len > (start + end + 0.4)
  scale_s <- ifelse(keep, start / len, 0)
  scale_e <- ifelse(keep, end / len, 0)
  df$x <- df$x + dx * scale_s
  df$y <- df$y + dy * scale_s
  df$xend <- df$xend - dx * scale_e
  df$yend <- df$yend - dy * scale_e
  df
}

#' Turn a set of orders into drawable arrows
#'
#' @param game A [dp_game] object.
#' @param orders A `dp_orders` tibble.
#' @param geom Board geometry.
#' @return A tibble with `x`, `y`, `xend`, `yend`, `power`, `kind` and
#'   `failed`, or `NULL` when there is nothing to draw.
#' @noRd
.dp_order_arrows <- function(game, orders, geom) {
  if (is.null(orders) || nrow(orders) == 0L) return(NULL)
  map <- game$map
  dy <- .dp_offsets()[["unit"]]
  from <- .loc_xy(map, orders$loc, geom)

  to_loc <- rep(NA_character_, nrow(orders))
  is_move <- orders$type %in% c("move", "retreat")
  to_loc[is_move] <- orders$target[is_move]
  is_aux <- orders$type %in% c("support", "convoy")
  to_loc[is_aux] <- ifelse(is.na(orders$aux_target[is_aux]),
                           orders$aux_loc[is_aux],
                           orders$aux_target[is_aux])
  drawable <- !is.na(to_loc) & !is.na(from$x)
  if (!any(drawable)) return(NULL)

  to <- .loc_xy(map, to_loc[drawable], geom)
  ok <- if ("success" %in% names(orders)) orders$success[drawable] else NA
  out <- tibble::tibble(
    x = from$x[drawable], y = from$y[drawable] + dy,
    xend = to$x, yend = to$y + dy,
    power = orders$power[drawable],
    kind = ifelse(orders$type[drawable] == "retreat", "retreat",
                  orders$type[drawable]),
    failed = !is.na(ok) & !ok
  )
  out <- out[!is.na(out$xend) & !is.na(out$yend), , drop = FALSE]
  if (nrow(out) == 0L) return(NULL)
  # Keep the untrimmed destination: the failure cross belongs on the province
  # that was contested, not on each arrowhead. Several orders bouncing off one
  # province would otherwise stack a blot of crosses around its edge.
  hit <- out[, c("xend", "yend")]
  out <- .dp_trim(out)
  out$hitx <- hit$xend
  out$hity <- hit$yend
  out
}

#' Add the order layers to a board plot
#'
#' @param p A \pkg{ggplot2} object.
#' @param arrows Output of [.dp_order_arrows()].
#' @return `p`, with the order layers added.
#' @noRd
.dp_add_orders <- function(p, arrows) {
  if (is.null(arrows)) return(p)
  head_move <- ggplot2::arrow(angle = 20, type = "closed",
                              length = ggplot2::unit(2.4, "mm"))
  head_thin <- ggplot2::arrow(angle = 22, type = "open",
                              length = ggplot2::unit(1.8, "mm"))
  # Supports and convoys were the faintest marks on the board and the hardest
  # to tell apart. They now differ in weight as well as dash, and a convoy is
  # a long dash-dot rather than a fine dotted trail.
  parts <- list(
    list(kinds = c("move", "retreat"), lt = "solid", lw = 0.8,
         head = head_move, alpha = 0.95),
    list(kinds = "support", lt = "42", lw = 0.6, head = head_thin,
         alpha = 0.9),
    list(kinds = "convoy", lt = "1232", lw = 0.7, head = head_thin,
         alpha = 0.9)
  )
  for (part in parts) {
    dat <- arrows[arrows$kind %in% part$kinds, , drop = FALSE]
    if (nrow(dat) == 0L) next
    p <- p +
      # A pale casing under every arrow, so that a light power colour still
      # reads where it crosses a sea.
      ggplot2::geom_curve(
        data = dat,
        ggplot2::aes(x = .data$x, y = .data$y, xend = .data$xend,
                     yend = .data$yend),
        curvature = 0.09, linewidth = part$lw + 0.7, colour = "white",
        lineend = "butt", alpha = 0.75, show.legend = FALSE
      ) +
      ggplot2::geom_curve(
        data = dat,
        ggplot2::aes(x = .data$x, y = .data$y, xend = .data$xend,
                     yend = .data$yend, colour = .data$power),
        curvature = 0.09, linewidth = part$lw, arrow = part$head,
        lineend = "butt", linetype = part$lt,
        alpha = part$alpha, show.legend = FALSE
      )
  }
  bounced <- arrows[arrows$failed, , drop = FALSE]
  if (nrow(bounced) > 0L) {
    # One cross per contested province, on the province rather than on each
    # arrowhead, so that a three-way bounce does not become a blot.
    bounced <- bounced[!duplicated(round(cbind(bounced$hitx, bounced$hity), 2)),
                       , drop = FALSE]
    p <- p +
      ggplot2::geom_point(
        data = bounced,
        ggplot2::aes(x = .data$hitx, y = .data$hity),
        shape = 4, size = 2.8, stroke = 1.6, colour = "white",
        show.legend = FALSE
      ) +
      ggplot2::geom_point(
        data = bounced,
        ggplot2::aes(x = .data$hitx, y = .data$hity),
        shape = 4, size = 2.3, stroke = 0.9, colour = "#9E2B2B",
        show.legend = FALSE
      )
  }
  p
}

#' The orders a game last resolved
#'
#' Prefers the adjudicated copy on `last_result`, which carries the `success`
#' column that marks the failed arrows; falls back to the orders as submitted.
#' Warns rather than drawing an empty board, which is what a bare `NULL` used
#' to do.
#'
#' @param game A [dp_game] object.
#' @param call Caller environment, for the warning.
#' @return A `dp_orders` tibble, or `NULL`.
#' @noRd
.dp_resolved_orders <- function(game, call = rlang::caller_env()) {
  out <- game$last_result$orders %||% game$last_orders
  if (is.null(out) || nrow(out) == 0L) {
    cli::cli_warn(
      c("This game has no resolved orders to draw.",
        i = "{.code orders = TRUE} needs a game returned by {.fun dp_step} or
             {.fun dp_advance}; pass a {.cls dp_orders} tibble instead."),
      call = call
    )
    return(NULL)
  }
  out
}

#' Draw the board
#'
#' Renders the board as a map. Every province is drawn as a territory rather
#' than a point: seas in blue, coastal land and inland in two shades of buff,
#' with coastlines picked out against the province borders. A supply centre
#' wears its name on a chip coloured for the power that holds it, so the balance
#' of the game is visible at a glance. Units are tokens in their power's colour
#' -- a circle for an army, a diamond for a fleet -- and units awaiting a
#' retreat are ringed in red.
#'
#' Terrain and ownership are deliberately encoded in different ways. Terrain
#' gets the large quiet fills and ownership the small saturated chips, because
#' washing a power's colour across a whole province makes a blue power's land
#' look like sea.
#'
#' Pass `orders` to draw the turn on the board: solid arrows for moves and
#' retreats, dashed for supports, dash-dotted for convoys. If the orders have
#' been adjudicated, and so carry a `success` column, the arrows that failed are
#' marked with a cross at their head.
#'
#' The board is schematic. Provinces sit at fixed coordinates and their shapes
#' come from tessellating the plane between them, so the outlines are
#' suggestive of Europe rather than a faithful coastline.
#'
#' The board is close to square. Give it a close-to-square figure: the default
#' `7 x 5` of many rendering setups leaves a third of the width empty and
#' squeezes the province names together.
#'
#' @param game A [dp_game] object.
#' @param orders Optional orders to draw over the board, as a `dp_orders`
#'   tibble. `TRUE` draws the orders the game last resolved, if it has any.
#' @param labels Draw the three-letter province codes. Default `TRUE`.
#' @param ownership Colour each supply centre's chip for the power that holds
#'   it. Default `TRUE`; `FALSE` leaves every chip neutral.
#' @param title Plot title. `NULL` uses the current turn.
#' @param subtitle Plot subtitle. `NULL` summarises the position.
#' @return A \pkg{ggplot2} object.
#' @export
#' @family plot
#' @examples
#' dp_plot_map(dp_new_game())
#'
#' g <- dp_new_game()
#' dp_plot_map(g, orders = dp_example_orders())
dp_plot_map <- function(game, orders = NULL, labels = TRUE, ownership = TRUE,
                        title = NULL, subtitle = NULL) {
  .check_game(game)
  .check_flag(labels)
  .check_flag(ownership)
  if (isTRUE(orders)) orders <- .dp_resolved_orders(game)
  if (isFALSE(orders)) orders <- NULL
  if (!is.null(orders) && !is.data.frame(orders)) {
    cli::cli_abort("{.arg orders} must be a {.cls dp_orders} tibble.")
  }

  map <- game$map
  geom <- .dp_board_geom(map)
  prov <- map$provinces
  off <- .dp_offsets()
  ink <- .dp_ink()
  pal <- dp_palette()

  cells <- geom$cells
  cells$fill <- .dp_province_fill(game)[match(cells$code, prov$code)]
  anchor <- geom$anchor
  anchor$type <- prov$type[match(anchor$code, prov$code)]
  anchor$supply_centre <- prov$supply_centre[match(anchor$code, prov$code)]

  # The name sits on the centroid unless a unit token needs the room.
  units <- game$units
  occupied <- unique(.province(units$loc))
  anchor$busy <- anchor$code %in% occupied
  anchor$ly <- anchor$y + ifelse(anchor$busy, off[["label"]], 0)

  bd <- geom$borders
  p <- ggplot2::ggplot() +
    ggplot2::geom_raster(
      data = cells,
      ggplot2::aes(x = .data$x, y = .data$y, fill = .data$fill)
    ) +
    ggplot2::geom_segment(
      data = bd[bd$kind == "inner", , drop = FALSE],
      ggplot2::aes(x = .data$x, y = .data$y, xend = .data$xend,
                   yend = .data$yend),
      colour = ink[["border"]], linewidth = 0.26
    ) +
    ggplot2::geom_segment(
      data = bd[bd$kind == "coast", , drop = FALSE],
      ggplot2::aes(x = .data$x, y = .data$y, xend = .data$xend,
                   yend = .data$yend),
      colour = ink[["coastline"]], linewidth = 0.28
    ) +
    ggplot2::scale_fill_identity(
      name = "Terrain", guide = "legend",
      breaks = unname(.dp_terrain()[c("sea", "coast", "land")]),
      labels = c("Sea", "Coastal land", "Inland")
    )

  # Order arrows go under the names: an arrow crossing a province is easy to
  # follow through a name, a name overdrawn by an arrow is not readable.
  arrows <- .dp_order_arrows(game, orders, geom)
  p <- .dp_add_orders(p, arrows)

  if (labels) {
    plain <- anchor[!anchor$supply_centre, , drop = FALSE]
    if (nrow(plain) > 0L) {
      p <- p + ggplot2::geom_text(
        data = plain,
        ggplot2::aes(x = .data$x, y = .data$ly, label = toupper(.data$code)),
        size = 2.05, fontface = "bold",
        colour = ifelse(plain$type == "sea", ink[["sea_label"]],
                        ink[["label"]])
      )
    }
    # A supply centre wears its owner's colour as a chip around its name. The
    # colour is saturated but small, which keeps ownership legible without
    # washing a blue power across a province until it looks like sea.
    centres <- anchor[anchor$supply_centre, , drop = FALSE]
    if (nrow(centres) > 0L) {
      chip <- .dp_centre_chip(game, centres$code, ownership)
      p <- p + ggplot2::geom_label(
        data = centres,
        ggplot2::aes(x = .data$x, y = .data$ly, label = toupper(.data$code)),
        size = 2.05, fontface = "bold", colour = chip$ink, fill = chip$fill,
        linewidth = 0.3, label.r = ggplot2::unit(0.32, "lines"),
        label.padding = ggplot2::unit(0.13, "lines")
      )
    }
  }

  if (nrow(units) > 0L) {
    xy <- .loc_xy(map, units$loc, geom)
    units$x <- xy$x
    units$y <- xy$y + off[["unit"]]
    units$glyph <- .fmt_unit(units$type)
    p <- p +
      ggplot2::geom_point(
        data = units,
        ggplot2::aes(x = .data$x, y = .data$y, shape = .data$type),
        size = 5.9, colour = "white", show.legend = FALSE
      ) +
      ggplot2::geom_point(
        data = units,
        ggplot2::aes(x = .data$x, y = .data$y, shape = .data$type,
                     colour = .data$power),
        size = 4.6
      ) +
      ggplot2::geom_text(
        data = units,
        ggplot2::aes(x = .data$x, y = .data$y, label = .data$glyph),
        size = 1.9, fontface = "bold",
        colour = .dp_on_colour(unname(pal[units$power]))
      )
  }

  if (nrow(game$dislodged) > 0L) {
    dxy <- .loc_xy(map, game$dislodged$loc, geom)
    dxy$y <- dxy$y + off[["unit"]]
    p <- p + ggplot2::geom_point(
      data = dxy, ggplot2::aes(x = .data$x, y = .data$y),
      shape = 21, size = 7.2, stroke = 0.9, fill = NA, colour = "#B2182B"
    )
  }

  # Every power and both unit types keep their legend key whether or not they
  # are on the board. A key is drawn from the layer's own data, so without these
  # two invisible layers an eliminated power -- or a position with no fleet left
  # -- shows a legend entry with a label and no glyph beside it.
  at_x <- geom$range$x[[1L]]
  at_y <- geom$range$y[[1L]]
  key <- tibble::tibble(power = names(pal), x = at_x, y = at_y)
  ukey <- tibble::tibble(type = c("army", "fleet"), x = at_x, y = at_y)
  p +
    ggplot2::geom_point(
      data = key,
      ggplot2::aes(x = .data$x, y = .data$y, colour = .data$power),
      shape = 16, size = 0.1, alpha = 0
    ) +
    ggplot2::geom_point(
      data = ukey,
      ggplot2::aes(x = .data$x, y = .data$y, shape = .data$type),
      colour = "grey25", size = 0.1, alpha = 0
    ) +
    ggplot2::scale_colour_manual(values = pal, name = "Power",
                                 limits = names(pal), drop = FALSE) +
    ggplot2::scale_shape_manual(
      values = c(army = 16, fleet = 18), name = "Unit",
      limits = c("army", "fleet"), labels = c("Army", "Fleet"), drop = FALSE
    ) +
    ggplot2::coord_equal(expand = FALSE, clip = "off") +
    ggplot2::labs(
      title = title %||% paste0("Diplomacy \u2014 ", .turn_label(game)),
      subtitle = subtitle %||% .dp_map_subtitle(game, arrows),
      caption = .dp_map_caption(ownership, arrows, labels),
      x = NULL, y = NULL
    ) +
    ggplot2::guides(
      # Two rows: seven powers on one row is wider than the figures this
      # package's own vignettes render at, and the row overflows the device.
      colour = ggplot2::guide_legend(
        order = 1, nrow = 2,
        override.aes = list(size = 3.2, shape = 16, alpha = 1, linetype = 0)
      ),
      shape = ggplot2::guide_legend(order = 2, nrow = 1,
                                    override.aes = list(size = 3.2, alpha = 1,
                                                        colour = "grey25")),
      fill = ggplot2::guide_legend(order = 3, nrow = 1,
                                   override.aes = list(shape = 22, size = 3.6,
                                                       stroke = 0.2))
    ) +
    .dp_theme_map()
}

#' One-line description of the position
#'
#' @param game A [dp_game] object.
#' @param arrows Order arrows, or `NULL`.
#' @return A single string.
#' @noRd
.dp_map_subtitle <- function(game, arrows = NULL) {
  n_units <- nrow(game$units)
  owned <- sum(!is.na(game$sc_owner))
  bits <- c(
    paste0(n_units, " unit", if (n_units == 1L) "" else "s"),
    paste0(owned, " of ", length(game$map$supply_centres),
           " supply centres owned")
  )
  if (!is.null(arrows)) {
    bits <- c(bits, paste0(nrow(arrows), " order",
                           if (nrow(arrows) == 1L) "" else "s", " drawn"))
  }
  if (nrow(game$dislodged) > 0L) {
    bits <- c(bits, paste0(nrow(game$dislodged), " awaiting retreat"))
  }
  paste(bits, collapse = "  \u00b7  ")
}

#' Caption explaining the board's conventions
#'
#' Kept to short lines: a caption long enough to need wrapping is silently
#' clipped at the figure sizes this package's vignettes use.
#'
#' @param ownership Whether the chips are coloured by owner.
#' @param arrows Order arrows, or `NULL`.
#' @param labels Whether the province names, and so the chips, are drawn.
#' @return A single string.
#' @noRd
.dp_map_caption <- function(ownership, arrows = NULL, labels = TRUE) {
  bits <- character(0)
  # Without the names there are no chips to explain.
  if (labels) {
    bits <- paste0(
      "Supply centres are named on a chip",
      if (ownership) ", in the colour of the power holding them" else "",
      "."
    )
  }
  if (!is.null(arrows)) {
    bits <- c(
      bits,
      paste0("Arrows: solid move, dashed support, dash-dot convoy",
             if (any(arrows$failed)) "; \u00d7 marks an order that failed"
             else "", ".")
    )
  }
  bits <- c(bits, "Schematic board: provinces are tessellated between fixed
                   coordinates.")
  paste(gsub("\\s+", " ", bits), collapse = "\n")
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
