# Supply centres, victory and adjustment arithmetic ----------------------------

#' @rdname dp_supply_centres
#' @export
dp_supply_centres.dp_game <- function(x, ...) {
  rlang::check_dots_empty()
  base <- dp_supply_centres(x$map)
  owner <- unname(x$sc_owner[base$centre])
  occ_idx <- .unit_index(x$units, base$centre)
  base$owner <- ifelse(is.na(owner), NA_character_, owner)
  base$occupied_by <- ifelse(is.na(occ_idx), NA_character_,
                             x$units$power[occ_idx])
  base
}

#' Count supply centres and units per power
#'
#' @param game A [dp_game] object.
#' @return A tibble with columns `power`, `centres`, `units` and `delta`,
#'   one row per power, ordered by centres.
#' @export
#' @family analysis
#' @examples
#' dp_power_counts(dp_new_game())
dp_power_counts <- function(game) {
  .check_game(game)
  centres <- vapply(game$powers, function(p) sum(game$sc_owner == p),
                    integer(1))
  units <- vapply(game$powers, function(p) sum(game$units$power == p),
                  integer(1))
  out <- tibble::tibble(
    power = game$powers,
    centres = unname(centres),
    units = unname(units),
    delta = unname(centres - units)
  )
  out[order(-out$centres, out$power), , drop = FALSE]
}

#' Transfer supply-centre ownership
#'
#' Ownership changes only after the autumn retreats: every centre occupied by
#' a unit passes to that unit's power, and unoccupied centres keep their
#' previous owner.
#'
#' @param game A [dp_game] object.
#' @return The game with `sc_owner` updated.
#' @noRd
.update_sc_ownership <- function(game) {
  sc <- game$map$supply_centres
  idx <- .unit_index(game$units, sc)
  new_owner <- game$sc_owner
  occupied <- !is.na(idx)
  new_owner[sc[occupied]] <- game$units$power[idx[occupied]]
  game$sc_owner <- new_owner
  game
}

#' Build or disband requirement for a power
#'
#' @param game A [dp_game] object.
#' @param power A power.
#' @return An integer: positive means builds are due, negative disbands.
#' @noRd
.build_delta <- function(game, power) {
  sum(game$sc_owner == power) - sum(game$units$power == power)
}

#' Home centres where a power may build
#'
#' @param game A [dp_game] object.
#' @param power A power.
#' @return A character vector of province codes.
#' @noRd
.build_sites <- function(game, power) {
  home <- game$map$home_centres[[power]] %||% character(0)
  owned <- home[!is.na(game$sc_owner[home]) & game$sc_owner[home] == power]
  owned[is.na(.unit_index(game$units, owned))]
}

#' Provinces an army may step to when its distance is measured
#'
#' For the civil-disorder rule an army counts as able to move like a fleet as
#' well, so a sea crossing costs one move per sea province and coasts do not
#' matter.
#'
#' @param map A [dp_map] object.
#' @param prov A province code.
#' @return A character vector of province codes.
#' @noRd
.mixed_adj <- function(map, prov) {
  locs <- c(prov, .coasts_of(map, prov))
  sea <- unlist(lapply(locs, function(l) map$fleet_adj[[l]] %||% character(0)),
                use.names = FALSE)
  unique(c(map$army_adj[[prov]] %||% character(0), .province(sea)))
}

#' Shortest-path distance from a unit to its nearest home centre
#'
#' Fleets move as fleets. Armies are treated as able to move like a fleet too,
#' which is the standard reading of "the shortest available route, including
#' convoys" for the civil-disorder rule. An unreachable home gives an
#' effectively infinite distance.
#'
#' @param map A [dp_map] object.
#' @param type `"army"` or `"fleet"`.
#' @param loc Location of the unit.
#' @param homes Character vector of home supply centres.
#' @return A numeric distance in moves.
#' @noRd
.home_distance <- function(map, type, loc, homes) {
  if (length(homes) == 0L) return(Inf)
  start <- if (type == "army") .province(loc) else loc
  if (.province(start) %in% homes) return(0)
  seen <- start
  frontier <- start
  d <- 0
  while (length(frontier) > 0L && d < 100L) {
    d <- d + 1
    nxt <- unique(unlist(lapply(frontier, function(l) {
      if (type == "army") {
        .mixed_adj(map, .province(l))
      } else {
        map$fleet_adj[[l]] %||% character(0)
      }
    }), use.names = FALSE))
    nxt <- setdiff(nxt, seen)
    if (length(nxt) == 0L) return(Inf)
    if (any(.province(nxt) %in% homes)) return(d)
    seen <- c(seen, nxt)
    frontier <- nxt
  }
  Inf
}

#' Order units for civil-disorder removal
#'
#' The furthest unit from home goes first; at equal distance a fleet goes
#' before an army; ties are broken alphabetically by province.
#'
#' @param game A [dp_game] object.
#' @param power A power.
#' @return An integer vector of row indices into the units tibble.
#' @noRd
.civil_disorder_order <- function(game, power) {
  idx <- which(game$units$power == power)
  if (length(idx) == 0L) return(integer(0))
  homes <- game$map$home_centres[[power]] %||% character(0)
  dist <- vapply(idx, function(i) {
    .home_distance(game$map, game$units$type[i], game$units$loc[i], homes)
  }, numeric(1))
  rank_type <- ifelse(game$units$type[idx] == "fleet", 0L, 1L)
  idx[order(-dist, rank_type, .province(game$units$loc[idx]))]
}

#' Check for a solo victory or a draw
#'
#' A power wins outright by controlling `threshold` supply centres, 18 of the
#' 34 on the standard board. A game that reaches its turn cap without a solo
#' ends in a draw between the surviving powers.
#'
#' @param game A [dp_game] object.
#' @param threshold Centres needed for a solo victory. Default `18`.
#' @return A list with `winner` (a power or `NA`), `over` (logical),
#'   `outcome` (`"solo"`, `"draw"` or `NA`), `survivors` and the per-power
#'   `counts` tibble.
#' @export
#' @family analysis
#' @examples
#' dp_victory_check(dp_new_game())
dp_victory_check <- function(game, threshold = 18L) {
  .check_game(game)
  threshold <- .check_count(threshold, min = 1L)
  counts <- dp_power_counts(game)
  survivors <- counts$power[counts$centres > 0L | counts$units > 0L]
  winner <- counts$power[counts$centres >= threshold]
  if (length(winner) > 0L) {
    return(list(winner = winner[1], over = TRUE, outcome = "solo",
                survivors = survivors, counts = counts))
  }
  if (length(survivors) == 1L) {
    return(list(winner = survivors, over = TRUE, outcome = "solo",
                survivors = survivors, counts = counts))
  }
  list(winner = NA_character_, over = FALSE, outcome = NA_character_,
       survivors = survivors, counts = counts)
}
