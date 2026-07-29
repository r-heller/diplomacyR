# Worked examples --------------------------------------------------------------

#' Example game positions
#'
#' Ready-made board states for documentation, tests and the Shiny app.
#'
#' @param state Which position to build:
#'   * `"opening"` -- Spring 1901, the canonical starting position.
#'   * `"midgame"` -- a contested Fall 1903 position.
#'   * `"retreat"` -- a retreat phase with one dislodged fleet.
#'   * `"build"` -- an adjustment phase with builds and a disband due.
#'   * `"solo"` -- a position in which one power holds 18 centres.
#' @param map A [dp_map] object.
#' @return A [dp_game] object.
#' @export
#' @family setup
#' @examples
#' dp_example_game()
#' dp_example_game("retreat")
dp_example_game <- function(state = c("opening", "midgame", "retreat", "build",
                                      "solo"),
                            map = dp_map()) {
  state <- rlang::arg_match(state)
  switch(state,
    opening = dp_new_game(map),
    midgame = .example_midgame(map),
    retreat = .example_retreat(map),
    build = .example_build(map),
    solo = .example_solo(map)
  )
}

#' @noRd
.example_midgame <- function(map) {
  units <- tibble::tribble(
    ~power,     ~type,   ~loc,
    "Austria",  "army",  "bud",
    "Austria",  "army",  "ser",
    "Austria",  "fleet", "tri",
    "England",  "fleet", "nth",
    "England",  "fleet", "nwy",
    "England",  "army",  "yor",
    "France",   "army",  "bur",
    "France",   "army",  "spa",
    "France",   "fleet", "mao",
    "Germany",  "army",  "mun",
    "Germany",  "army",  "ber",
    "Germany",  "fleet", "den",
    "Italy",    "army",  "ven",
    "Italy",    "fleet", "ion",
    "Italy",    "army",  "tun",
    "Russia",   "army",  "war",
    "Russia",   "army",  "ukr",
    "Russia",   "fleet", "sev",
    "Russia",   "fleet", "swe",
    "Turkey",   "army",  "bul",
    "Turkey",   "fleet", "bla",
    "Turkey",   "army",  "smy"
  )
  owner <- c(
    bud = "Austria", tri = "Austria", vie = "Austria", ser = "Austria",
    edi = "England", lon = "England", lvp = "England", nwy = "England",
    bre = "France", mar = "France", par = "France", spa = "France",
    por = "France", ber = "Germany", kie = "Germany", mun = "Germany",
    den = "Germany", hol = "Germany", nap = "Italy", rom = "Italy",
    ven = "Italy", tun = "Italy", mos = "Russia", sev = "Russia",
    stp = "Russia", war = "Russia", swe = "Russia", rum = "Russia",
    ank = "Turkey", con = "Turkey", smy = "Turkey", bul = "Turkey",
    gre = "Turkey", bel = "Germany"
  )
  dp_game_from_units(units, map = map, season = "Fall", year = 1903,
                     phase = "movement", sc_owner = owner)
}

#' @noRd
.example_retreat <- function(map) {
  units <- tibble::tribble(
    ~power,    ~type,  ~loc,
    "Italy",   "army", "tri",
    "Italy",   "army", "tyr",
    "Austria", "army", "vie",
    "Austria", "army", "bud"
  )
  dislodged <- tibble::tibble(
    power = "Austria", type = "fleet", loc = "tri", from = "ven",
    by_convoy = FALSE
  )
  dp_game_from_units(units, map = map, season = "Spring", year = 1902,
                     phase = "retreat", dislodged = dislodged)
}

#' @noRd
.example_build <- function(map) {
  units <- tibble::tribble(
    ~power,    ~type,   ~loc,
    "Germany", "army",  "mun",
    "Germany", "fleet", "kie",
    "Germany", "army",  "sil",
    "Russia",  "army",  "war",
    "Russia",  "army",  "ukr",
    "Russia",  "fleet", "sev"
  )
  owner <- c(
    ber = "Germany", kie = "Germany", mun = "Germany", den = "Germany",
    hol = "Germany", war = "Russia", mos = "Russia"
  )
  dp_game_from_units(units, map = map, season = "Winter", year = 1902,
                     phase = "build", sc_owner = owner)
}

#' @noRd
.example_solo <- function(map) {
  centres <- c(
    "ber", "kie", "mun", "den", "hol", "bel", "par", "bre", "mar", "spa",
    "por", "lon", "edi", "lvp", "nwy", "swe", "war", "vie"
  )
  owner <- stats::setNames(rep("Germany", length(centres)), centres)
  units <- tibble::tibble(
    power = "Germany", type = "army", loc = c("ber", "kie", "mun")
  )
  dp_game_from_units(units, map = map, season = "Winter", year = 1908,
                     phase = "build", sc_owner = owner)
}

#' Example order sets
#'
#' Complete, legal order sets that go with [dp_example_game()].
#'
#' @param phase Which set to build:
#'   * `"spring_1901"` -- a plausible opening for all seven powers.
#'   * `"fall_1901"` -- a follow-up set for the same position.
#'   * `"retreat"` -- the retreat that goes with
#'     `dp_example_game("retreat")`.
#'   * `"build"` -- the adjustments that go with `dp_example_game("build")`.
#' @param map A [dp_map] object.
#' @return A `dp_orders` tibble.
#' @export
#' @family orders
#' @examples
#' dp_example_orders("spring_1901")
dp_example_orders <- function(phase = c("spring_1901", "fall_1901", "retreat",
                                        "build"),
                              map = dp_map()) {
  phase <- rlang::arg_match(phase)
  txt <- switch(phase,
    spring_1901 = c(
      "Austria: A Vie - Tri", "Austria: A Bud - Ser", "Austria: F Tri - Alb",
      "England: F Lon - Nth", "England: F Edi - Nwg", "England: A Lvp - Yor",
      "France: A Par - Bur", "France: A Mar - Spa", "France: F Bre - Mao",
      "Germany: A Ber - Kie", "Germany: A Mun - Ruh", "Germany: F Kie - Den",
      "Italy: A Ven - Pie", "Italy: A Rom - Ven", "Italy: F Nap - Ion",
      "Russia: A Mos - Ukr", "Russia: A War - Gal", "Russia: F Sev - Bla",
      "Russia: F Stp/sc - Bot",
      "Turkey: F Ank - Bla", "Turkey: A Con - Bul", "Turkey: A Smy - Con"
    ),
    fall_1901 = c(
      "Austria: A Tri H", "Austria: A Ser - Gre", "Austria: F Alb S A Ser - Gre",
      "England: F Nth - Nwy", "England: F Nwg S F Nth - Nwy",
      "England: A Yor H",
      "France: A Bur - Bel", "France: A Spa H", "France: F Mao - Por",
      "Germany: A Kie - Hol", "Germany: A Ruh S A Kie - Hol",
      "Germany: F Den H",
      "Italy: A Pie H", "Italy: A Ven H", "Italy: F Ion - Tun",
      "Russia: A Ukr - Rum", "Russia: A Gal S A Ukr - Rum",
      "Russia: F Bla S A Ukr - Rum", "Russia: F Bot - Swe",
      "Turkey: F Ank - Con", "Turkey: A Bul H", "Turkey: A Con - Smy"
    ),
    retreat = "Austria: F Tri R Alb",
    build = c("Germany: Build A Ber", "Germany: Build F Hol")
  )
  ph <- if (phase == "retreat") "retreat" else if (phase == "build") {
    "build"
  } else {
    "movement"
  }
  dp_parse_orders(txt, phase = ph, map = map)
}
