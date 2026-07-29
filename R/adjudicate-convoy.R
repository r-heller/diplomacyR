# Convoys ---------------------------------------------------------------------
#
# A convoyed army travels from one coastal province to another along a chain of
# sea provinces, each occupied by a fleet explicitly ordered to convoy that
# exact move. The chain is only intact while none of those fleets is dislodged,
# so path resolution is entangled with the rest of the adjudication: this file
# resolves it lazily, one fleet at a time, so that the dependency stack in
# `adjudicate.R` sees only the convoys a path actually needs.

#' Sea provinces adjacent to a location for fleet movement
#'
#' @param map A [dp_map] object.
#' @param loc A location or province code.
#' @return A character vector of adjacent sea provinces.
#' @noRd
.adjacent_seas <- function(map, loc) {
  prov <- .province(loc)
  locs <- c(prov, .coasts_of(map, prov))
  nb <- unlist(lapply(locs, function(l) map$fleet_adj[[l]] %||% character(0)),
               use.names = FALSE)
  nb <- unique(.province(nb))
  nb[.province_type(map, nb) == "sea"]
}

#' Coastal provinces adjacent to a sea province
#'
#' @param map A [dp_map] object.
#' @param sea A sea province code.
#' @return A character vector of adjacent coastal provinces.
#' @noRd
.adjacent_coasts <- function(map, sea) {
  nb <- unique(.province(map$fleet_adj[[sea]] %||% character(0)))
  nb[.province_type(map, nb) == "coast"]
}

#' Provinces reachable by convoy, given the fleets on the board
#'
#' Ignores whose fleets they are and whether a convoy has been ordered: this
#' is the set of destinations for which a convoy is *conceivable*, which is
#' what [dp_legal_orders()] needs to offer.
#'
#' @param game A [dp_game] object.
#' @param from Province the army starts in.
#' @param must_use Optional sea province the chain has to pass through.
#' @return A character vector of coastal provinces.
#' @noRd
.convoy_reachable <- function(game, from, must_use = NULL) {
  map <- game$map
  if (.province_type(map, from) != "coast") return(character(0))
  fleet_seas <- .province(
    game$units$loc[game$units$type == "fleet"]
  )
  fleet_seas <- fleet_seas[.province_type(map, fleet_seas) == "sea"]
  if (length(fleet_seas) == 0L) return(character(0))
  if (!is.null(must_use) && !must_use %in% fleet_seas) return(character(0))

  seen <- character(0)
  frontier <- intersect(.adjacent_seas(map, from), fleet_seas)
  while (length(frontier) > 0L) {
    seen <- union(seen, frontier)
    nxt <- unique(unlist(
      lapply(frontier, function(s) intersect(.adjacent_seas(map, s),
                                             fleet_seas)),
      use.names = FALSE
    ))
    frontier <- setdiff(nxt, seen)
  }
  if (!is.null(must_use)) {
    if (!must_use %in% seen) return(character(0))
    seen <- .convoy_component(map, fleet_seas, must_use)
    if (!from %in% unlist(lapply(seen, function(s) .adjacent_coasts(map, s)))) {
      return(character(0))
    }
  }
  dest <- unique(unlist(lapply(seen, function(s) .adjacent_coasts(map, s)),
                        use.names = FALSE))
  setdiff(dest, from)
}

#' Connected component of fleet-occupied seas containing a sea
#'
#' @param map A [dp_map] object.
#' @param fleet_seas Sea provinces occupied by fleets.
#' @param start Sea province to start from.
#' @return A character vector of sea provinces.
#' @noRd
.convoy_component <- function(map, fleet_seas, start) {
  seen <- start
  frontier <- start
  while (length(frontier) > 0L) {
    nxt <- unique(unlist(
      lapply(frontier, function(s) intersect(.adjacent_seas(map, s),
                                             fleet_seas)),
      use.names = FALSE
    ))
    frontier <- setdiff(nxt, seen)
    seen <- union(seen, frontier)
  }
  seen
}

#' Convoy destinations for every army, computed once
#'
#' @param game A [dp_game] object.
#' @return A named list mapping province to reachable coastal provinces.
#' @noRd
.convoy_reach_table <- function(game) {
  armies <- unique(.province(game$units$loc[game$units$type == "army"]))
  stats::setNames(lapply(armies, function(p) .convoy_reachable(game, p)),
                  armies)
}

#' Seas that could carry an army between two provinces
#'
#' Purely geographic: which sea provinces lie on at least one conceivable
#' convoy route from `src` to `dst`, ignoring where the fleets actually are.
#' Deciding intent needs this, because a fleet that orders a convoy from a sea
#' no route could ever use is not showing intent to convoy.
#'
#' @param map A [dp_map] object.
#' @param src Source province of the army.
#' @param dst Destination province.
#' @return A character vector of sea provinces.
#' @noRd
.seas_on_possible_route <- function(map, src, dst) {
  grow <- function(start) {
    seen <- start
    frontier <- start
    while (length(frontier) > 0L) {
      nxt <- unique(unlist(lapply(frontier, function(s) .adjacent_seas(map, s)),
                           use.names = FALSE))
      frontier <- setdiff(nxt, seen)
      seen <- union(seen, frontier)
    }
    seen
  }
  from_src <- grow(.adjacent_seas(map, src))
  to_dst <- grow(.adjacent_seas(map, dst))
  intersect(from_src, to_dst)
}

#' Is there an intact convoy path for a move?
#'
#' Depth-first search from the army's province through the sea provinces whose
#' fleets are ordered to convoy exactly this move, resolving each convoy order
#' only when the search actually needs it.
#'
#' @param st Resolver state environment.
#' @param i Index of the move order.
#' @return `TRUE` when at least one intact chain reaches the destination.
#' @noRd
.convoy_path_ok <- function(st, i) {
  fl <- st$convoy_for[[i]]
  if (length(fl) == 0L) return(FALSE)
  map <- st$map
  src <- .province(st$orders$loc[i])
  dst <- .province(st$orders$target[i])
  seas <- .province(st$orders$loc[fl])

  visit <- function(cur, used) {
    cands <- setdiff(intersect(.adjacent_seas(map, cur), seas), used)
    for (s in cands) {
      j <- fl[match(s, seas)]
      if (!.resolve(st, j)) next
      if (dst %in% .adjacent_coasts(map, s)) return(TRUE)
      if (visit(s, c(used, s))) return(TRUE)
    }
    FALSE
  }
  visit(src, character(0))
}

#' Adjudicate a convoy order
#'
#' A convoy succeeds unless the convoying fleet is dislodged.
#'
#' @param st Resolver state environment.
#' @param i Index of the convoy order.
#' @return `TRUE` when the fleet holds its sea.
#' @noRd
.adjudicate_convoy <- function(st, i) {
  prov <- .province(st$orders$loc[i])
  attackers <- st$moves_into[[prov]] %||% integer(0)
  for (j in attackers) {
    if (.resolve(st, j)) return(FALSE)
  }
  TRUE
}
