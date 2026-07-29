# Board geometry ---------------------------------------------------------------
#
# The province table gives one point per province. To draw a map rather than a
# scatter of points the package tessellates the plane: every cell of a fine
# raster is assigned to its nearest province, then clipped so the board has an
# outline. Province outlines fall out of the tessellation as the segments
# between cells of different provinces, and the label anchor of a province is
# the centroid of its territory rather than its seed point, which keeps labels
# inside the shape they belong to.
#
# Clipping on distance to the nearest seed alone is not enough: a province on
# the rim has no neighbour to bound it on the outside, so it grows into a full
# disc and the board turns into a cloud of bubbles. Cells are therefore also
# required to lie within a short distance of the convex hull of the seeds,
# which gives the board a coastline of roughly straight runs and keeps rim
# provinces the same size as interior ones.
#
# The result depends only on the board, so it is computed once and cached.

#' Cache for board geometries
#' @noRd
.dp_geom_cache <- new.env(parent = emptyenv())

#' Tessellate a board into province territories
#'
#' @param map A [dp_map] object.
#' @param res Raster resolution in board units.
#' @param radius Largest distance from a province seed that still counts as
#'   that province's territory.
#' @param edge How far beyond the convex hull of the seeds the board may
#'   extend. Sets the width of the rim provinces and so the board's outline.
#' @return A list with `cells` (a tibble of raster cells), `borders` (a tibble
#'   of segments classified as `"inner"`, `"coast"` or `"edge"`), `anchor` (a
#'   tibble of one label anchor per province) and `range` (the board extent).
#' @noRd
.dp_board_geom <- function(map, res = 0.18, radius = 13, edge = 2.4) {
  key <- paste(map$name, res, radius, edge, sep = "-")
  hit <- .dp_geom_cache[[key]]
  if (!is.null(hit)) return(hit)

  prov <- map$provinces
  pad <- min(radius, edge) + res
  gx <- seq(min(prov$x) - pad, max(prov$x) + pad, by = res)
  gy <- seq(min(prov$y) - pad, max(prov$y) + pad, by = res)
  nx <- length(gx)
  ny <- length(gy)

  # Nearest province for every raster cell, clipped to `radius` and to a band
  # of width `edge` around the hull of the seeds.
  cx <- rep(gx, times = ny)
  cy <- rep(gy, each = nx)
  d2 <- outer(cx, prov$x, "-")^2 + outer(cy, prov$y, "-")^2
  idx <- max.col(-d2, ties.method = "first")
  near <- sqrt(d2[cbind(seq_along(idx), idx)])
  outside <- .dp_hull_gap(cx, cy, prov$x, prov$y)
  idx[near > radius | outside > edge] <- NA_integer_
  mat <- matrix(idx, nrow = nx, ncol = ny)

  keep <- !is.na(idx)
  cells <- tibble::tibble(
    x = cx[keep],
    y = cy[keep],
    code = prov$code[idx[keep]],
    type = prov$type[idx[keep]]
  )

  # Territory centroids: a far better label anchor than the seed point, which
  # can sit close to a neighbour and push labels on top of each other.
  anchor <- tibble::tibble(
    code = prov$code,
    x = as.numeric(tapply(cells$x, cells$code, mean)[prov$code]),
    y = as.numeric(tapply(cells$y, cells$code, mean)[prov$code])
  )
  gone <- is.na(anchor$x)
  anchor$x[gone] <- prov$x[gone]
  anchor$y[gone] <- prov$y[gone]

  borders <- rbind(
    .dp_border_segments(mat, gx, gy, res, prov$type, axis = 1L),
    .dp_border_segments(mat, gx, gy, res, prov$type, axis = 2L)
  )

  out <- list(
    cells = cells,
    borders = borders,
    anchor = anchor,
    range = list(x = range(cells$x), y = range(cells$y))
  )
  assign(key, out, envir = .dp_geom_cache)
  out
}

#' How far each point lies outside the convex hull of a set of seeds
#'
#' Zero for points inside the hull, and the distance to the hull boundary for
#' points outside it. The hull is convex, so a point is inside exactly when it
#' is on the inner side of every edge, and the distance to the boundary is the
#' smallest distance to any edge segment.
#'
#' @param px,py Points to test.
#' @param sx,sy Seed coordinates whose hull is used.
#' @return A numeric vector as long as `px`.
#' @noRd
.dp_hull_gap <- function(px, py, sx, sy) {
  h <- grDevices::chull(sx, sy)
  hx <- sx[h]
  hy <- sy[h]
  n <- length(h)
  nxt <- c(seq_len(n)[-1L], 1L)
  # chull returns clockwise, so an interior point is on the right of every
  # edge and the cross product below is <= 0 throughout.
  inside <- rep(TRUE, length(px))
  best <- rep(Inf, length(px))
  for (i in seq_len(n)) {
    x1 <- hx[i]
    y1 <- hy[i]
    x2 <- hx[nxt[i]]
    y2 <- hy[nxt[i]]
    ex <- x2 - x1
    ey <- y2 - y1
    inside <- inside & (ex * (py - y1) - ey * (px - x1)) <= 0
    # distance from the point to this edge, treated as a segment
    len2 <- ex^2 + ey^2
    t <- if (len2 > 0) ((px - x1) * ex + (py - y1) * ey) / len2 else 0
    t <- pmin(pmax(t, 0), 1)
    best <- pmin(best, sqrt((px - (x1 + t * ex))^2 + (py - (y1 + t * ey))^2))
  }
  ifelse(inside, 0, best)
}

#' Border segments along one axis of the tessellation
#'
#' @param mat Integer matrix of province indices, `NA` off the board.
#' @param gx,gy Raster coordinates.
#' @param res Raster resolution.
#' @param type Province type, indexed as `mat`.
#' @param axis `1` for segments between horizontal neighbours, `2` for
#'   vertical.
#' @return A tibble with `x`, `y`, `xend`, `yend` and `kind`.
#' @noRd
.dp_border_segments <- function(mat, gx, gy, res, type, axis) {
  if (axis == 1L) {
    a <- mat[-nrow(mat), , drop = FALSE]
    b <- mat[-1L, , drop = FALSE]
  } else {
    a <- mat[, -ncol(mat), drop = FALSE]
    b <- mat[, -1L, drop = FALSE]
  }
  differs <- (is.na(a) != is.na(b)) | (!is.na(a) & !is.na(b) & a != b)
  hit <- which(differs, arr.ind = TRUE)
  if (nrow(hit) == 0L) {
    return(tibble::tibble(x = numeric(0), y = numeric(0), xend = numeric(0),
                          yend = numeric(0), kind = character(0)))
  }
  ia <- a[differs]
  ib <- b[differs]
  edge <- is.na(ia) | is.na(ib)
  sea_a <- !is.na(ia) & type[ia] == "sea"
  sea_b <- !is.na(ib) & type[ib] == "sea"
  kind <- ifelse(edge, "edge", ifelse(xor(sea_a, sea_b), "coast", "inner"))

  half <- res / 2
  if (axis == 1L) {
    x <- gx[hit[, 1L]] + half
    y <- gy[hit[, 2L]]
    tibble::tibble(x = x, y = y - half, xend = x, yend = y + half,
                   kind = kind)
  } else {
    x <- gx[hit[, 1L]]
    y <- gy[hit[, 2L]] + half
    tibble::tibble(x = x - half, y = y, xend = x + half, yend = y,
                   kind = kind)
  }
}

#' Display anchors for locations
#'
#' Territory centroids, nudged toward the named coast for coast-qualified
#' locations so that a fleet on `"stp/sc"` sits on the right side of the
#' province instead of floating outside it.
#'
#' @param map A [dp_map] object.
#' @param loc Character vector of locations, possibly coast-qualified.
#' @param geom Board geometry from [.dp_board_geom()].
#' @return A tibble with columns `loc`, `x` and `y`.
#' @noRd
.loc_xy <- function(map, loc, geom = .dp_board_geom(map)) {
  prov <- .province(loc)
  idx <- match(prov, geom$anchor$code)
  x <- geom$anchor$x[idx]
  y <- geom$anchor$y[idx]

  cidx <- match(loc, map$coast_xy$loc)
  has <- !is.na(cidx)
  if (any(has)) {
    seed <- match(prov[has], map$provinces$code)
    x[has] <- x[has] + 0.24 * (map$coast_xy$x[cidx[has]] -
                                 map$provinces$x[seed])
    y[has] <- y[has] + 0.24 * (map$coast_xy$y[cidx[has]] -
                                 map$provinces$y[seed])
  }
  tibble::tibble(loc = loc, x = x, y = y)
}
