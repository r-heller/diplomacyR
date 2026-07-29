# DATC harness ----------------------------------------------------------------
#
# Loads the encoded Diplomacy Adjudicator Test Cases from inst/extdata/datc and
# runs each one through the engine. Expected outcomes come from the DATC and
# are never derived from this package's own behaviour.

datc_file <- function(file = "datc_6a_6g.json") {
  system.file("extdata", "datc", file, package = "diplomacyR")
}

datc_cases <- function(section = NULL, file = "datc_6a_6g.json") {
  path <- datc_file(file)
  if (!nzchar(path)) return(list())
  cases <- jsonlite::read_json(path, simplifyVector = FALSE)$cases
  if (!is.null(section)) {
    keep <- vapply(cases, function(x) x$section %in% section, logical(1))
    cases <- cases[keep]
  }
  cases
}

datc_units <- function(lst) {
  if (length(lst) == 0L) {
    return(data.frame(power = character(0), type = character(0),
                      loc = character(0), stringsAsFactors = FALSE))
  }
  data.frame(
    power = vapply(lst, function(u) u$power, character(1)),
    type = vapply(lst, function(u) u$type, character(1)),
    loc = vapply(lst, function(u) u$loc, character(1)),
    stringsAsFactors = FALSE
  )
}

datc_key <- function(df) {
  if (nrow(df) == 0L) return(character(0))
  sort(paste(df$power, df$type, df$loc))
}

datc_sc_owner <- function(case) {
  if (length(case$sc_owners) == 0L) return(character(0))
  stats::setNames(
    vapply(case$sc_owners, function(o) o$power, character(1)),
    vapply(case$sc_owners, function(o) o$centre, character(1))
  )
}

# Reconstruct the dislodgements and standoffs of the movement phase that
# produced a retreat position, from the results the DATC records.
datc_prior_phase <- function(case, map) {
  res <- case$prestate_results
  parsed <- lapply(res, function(r) {
    o <- try(dp_parse_orders(r$order, power = r$power, map = map),
             silent = TRUE)
    if (inherits(o, "try-error") || nrow(o) == 0L) NULL else o
  })
  moves <- lapply(seq_along(parsed), function(k) {
    o <- parsed[[k]]
    if (is.null(o) || o$type[1] != "move") return(NULL)
    list(from = sub("/.*$", "", o$loc[1]), to = sub("/.*$", "", o$target[1]),
         success = isTRUE(res[[k]]$success),
         by_convoy = isTRUE(o$via_convoy[1]))
  })
  convoys <- Filter(function(o) !is.null(o) && o$type[1] == "convoy", parsed)
  convoyed <- vapply(
    convoys,
    function(o) paste(sub("/.*$", "", o$aux_loc[1]),
                      sub("/.*$", "", o$aux_target[1])),
    character(1)
  )
  moves <- Filter(Negate(is.null), moves)
  for (k in seq_along(moves)) {
    moves[[k]]$by_convoy <- moves[[k]]$by_convoy ||
      paste(moves[[k]]$from, moves[[k]]$to) %in% convoyed
  }
  to <- vapply(moves, function(m) m$to, character(1))
  ok <- vapply(moves, function(m) m$success, logical(1))
  contested <- unique(to[duplicated(to)])
  contested <- contested[vapply(contested, function(p) !any(ok[to == p]),
                                logical(1))]
  list(moves = moves, contested = contested)
}

datc_game <- function(case, map = dp_map()) {
  phase <- switch(case$phase,
    Movement = "movement",
    Retreat = "retreat",
    Adjustment = "build",
    "movement"
  )
  owner <- datc_sc_owner(case)
  if (length(owner) == 0L) owner <- NULL
  dislodged <- NULL
  contested <- character(0)
  if (phase == "retreat") {
    prior <- datc_prior_phase(case, map)
    contested <- prior$contested
    d <- datc_units(case$prestate_dislodged)
    if (nrow(d) > 0L) {
      from <- vapply(d$loc, function(l) {
        p <- sub("/.*$", "", l)
        hit <- Filter(function(m) m$success && m$to == p, prior$moves)
        if (length(hit) == 0L) NA_character_ else hit[[1]]$from
      }, character(1))
      by_convoy <- vapply(seq_len(nrow(d)), function(i) {
        if (is.na(from[i])) return(FALSE)
        p <- sub("/.*$", "", d$loc[i])
        hit <- Filter(function(m) m$success && m$to == p, prior$moves)
        if (length(hit) == 0L) return(FALSE)
        nb <- sub("/.*$", "", dp_adjacent(map, d$loc[i], d$type[i]))
        isTRUE(hit[[1]]$by_convoy) || !from[i] %in% nb
      }, logical(1))
      dislodged <- data.frame(
        power = d$power, type = d$type, loc = d$loc,
        from = ifelse(is.na(from), "", from), by_convoy = by_convoy,
        stringsAsFactors = FALSE
      )
    }
  }
  dp_game_from_units(
    datc_units(case$prestate), map = map,
    season = if (phase == "build") "Winter" else "Spring",
    year = 1901, phase = phase, sc_owner = owner,
    dislodged = dislodged, contested = contested
  )
}

datc_orders <- function(case, game) {
  txt <- unlist(case$orders, use.names = FALSE)
  if (length(txt) == 0L) return(NULL)
  dp_parse_orders(txt, phase = game$phase, map = game$map)
}

datc_resolve <- function(case, map = dp_map()) {
  g <- datc_game(case, map)
  o <- datc_orders(case, g)
  switch(g$phase,
    movement = dp_adjudicate(g, o),
    retreat = dp_retreat(g, o),
    build = dp_build(g, o)
  )
}

# The DATC omits dislodged units that have nowhere to retreat, so the unit
# positions are the binding assertion and the dislodged list is a lower bound.
expect_datc <- function(case, map = dp_map()) {
  res <- datc_resolve(case, map)
  expected <- datc_key(datc_units(case$poststate))
  got <- datc_key(res$units)
  testthat::expect_equal(got, expected, info = paste(case$id, case$description))
  if (case$phase == "Movement") {
    exp_d <- datc_key(datc_units(case$poststate_dislodged))
    got_d <- datc_key(res$dislodged[, c("power", "type", "loc")])
    testthat::expect_true(all(exp_d %in% got_d), info = case$id)
    testthat::expect_equal(
      nrow(res$dislodged),
      length(case$prestate) - length(case$poststate),
      info = case$id
    )
  }
  invisible(res)
}
