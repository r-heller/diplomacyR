# data-raw/standard_map.R -----------------------------------------------------
#
# Builds inst/extdata/standard_map.json, the canonical standard Diplomacy board.
#
# Input: data-raw/standard_map_abuts.txt, the adjacency table in the classic
# "judge" map format:
#
#   <TYPE> <LOCATION> ABUTS <locations ...>
#
# where TYPE is WATER, LAND or COAST and the case of each abutting location
# carries meaning: UPPERCASE entries are adjacencies open to the unit type
# native to that location (fleets, for water and coasts), lowercase entries
# are adjacencies open to armies only. Split coasts appear as separate
# locations (`bul/ec`, `spa/nc`, `stp/sc`, ...) alongside a lowercase entry
# for the province as a whole, which carries the army adjacency.
#
# Run with:  source("data-raw/standard_map.R")

abuts_file <- file.path("data-raw", "standard_map_abuts.txt")
stopifnot(file.exists(abuts_file))
lines <- readLines(abuts_file, warn = FALSE)
lines <- lines[grepl("ABUTS", lines, fixed = TRUE)]

parse_line <- function(x) {
  parts <- strsplit(trimws(x), "\\s+")[[1]]
  list(
    type = parts[1],
    loc = parts[2],
    abuts = parts[-c(1, 2, 3)]
  )
}
recs <- lapply(lines, parse_line)
names(recs) <- vapply(recs, function(r) tolower(r$loc), character(1))

# Switzerland is impassable and is not a province of the board.
recs <- recs[names(recs) != "swi"]

prov_of <- function(x) sub("/.*$", "", tolower(x))
is_coast_loc <- function(x) grepl("/", x, fixed = TRUE)

# Province types -------------------------------------------------------------
# A record whose LOCATION token is uppercase describes a province; lowercase
# tokens (`bul`, `spa`, `stp`) describe the army-level view of a split-coast
# province.
province_type <- c()
for (r in recs) {
  loc <- tolower(r$loc)
  if (is_coast_loc(loc)) next
  province_type[loc] <- switch(r$type,
    WATER = "sea",
    LAND = "land",
    COAST = "coast",
    stop("unknown type ", r$type)
  )
}
provinces <- sort(names(province_type))
stopifnot(length(provinces) == 75L)

# Adjacency ------------------------------------------------------------------
# Armies: every abutting entry (either case) that is not a sea, coasts stripped.
army_adj <- list()
for (p in provinces) {
  if (province_type[[p]] == "sea") {
    army_adj[[p]] <- character(0)
    next
  }
  r <- recs[[p]]
  nb <- unique(prov_of(r$abuts))
  nb <- setdiff(nb, "swi")
  nb <- nb[nb %in% provinces]
  nb <- nb[province_type[nb] != "sea"]
  army_adj[[p]] <- sort(unique(nb))
}

# Fleets: UPPERCASE entries only, and only to sea or coastal locations.
fleet_locs <- c(
  provinces[province_type[provinces] == "sea"],
  provinces[province_type[provinces] == "coast"]
)
split_coasts <- names(recs)[is_coast_loc(names(recs))]
fleet_locs <- sort(c(setdiff(fleet_locs, prov_of(split_coasts)), split_coasts))

fleet_adj <- list()
for (l in fleet_locs) {
  r <- recs[[l]]
  keep <- r$abuts[r$abuts == toupper(r$abuts)]
  keep <- tolower(keep)
  keep <- setdiff(keep, "swi")
  keep <- keep[prov_of(keep) %in% provinces]
  keep <- keep[province_type[prov_of(keep)] != "land"]
  # A fleet on an unsplit coast reaches a split-coast province only via one of
  # its named coasts, which the source file already spells out.
  fleet_adj[[l]] <- sort(unique(keep))
}

# Coast membership -----------------------------------------------------------
coasts <- list()
for (p in provinces) {
  cs <- split_coasts[prov_of(split_coasts) == p]
  coasts[[p]] <- sort(sub("^.*/", "", cs))
}

# Powers, supply centres, home centres, starting units -----------------------
powers <- c(
  "Austria", "England", "France", "Germany", "Italy", "Russia", "Turkey"
)

home_centres <- list(
  Austria = c("bud", "tri", "vie"),
  England = c("edi", "lon", "lvp"),
  France  = c("bre", "mar", "par"),
  Germany = c("ber", "kie", "mun"),
  Italy   = c("nap", "rom", "ven"),
  Russia  = c("mos", "sev", "stp", "war"),
  Turkey  = c("ank", "con", "smy")
)

neutral_centres <- c(
  "bel", "bul", "den", "gre", "hol", "nwy",
  "por", "rum", "ser", "spa", "swe", "tun"
)

supply_centres <- sort(c(unlist(home_centres, use.names = FALSE), neutral_centres))
stopifnot(length(supply_centres) == 34L)

start_units <- list(
  list(power = "Austria", type = "army",  loc = "bud"),
  list(power = "Austria", type = "army",  loc = "vie"),
  list(power = "Austria", type = "fleet", loc = "tri"),
  list(power = "England", type = "fleet", loc = "edi"),
  list(power = "England", type = "fleet", loc = "lon"),
  list(power = "England", type = "army",  loc = "lvp"),
  list(power = "France",  type = "fleet", loc = "bre"),
  list(power = "France",  type = "army",  loc = "mar"),
  list(power = "France",  type = "army",  loc = "par"),
  list(power = "Germany", type = "fleet", loc = "kie"),
  list(power = "Germany", type = "army",  loc = "ber"),
  list(power = "Germany", type = "army",  loc = "mun"),
  list(power = "Italy",   type = "fleet", loc = "nap"),
  list(power = "Italy",   type = "army",  loc = "rom"),
  list(power = "Italy",   type = "army",  loc = "ven"),
  list(power = "Russia",  type = "army",  loc = "war"),
  list(power = "Russia",  type = "army",  loc = "mos"),
  list(power = "Russia",  type = "fleet", loc = "sev"),
  list(power = "Russia",  type = "fleet", loc = "stp/sc"),
  list(power = "Turkey",  type = "fleet", loc = "ank"),
  list(power = "Turkey",  type = "army",  loc = "con"),
  list(power = "Turkey",  type = "army",  loc = "smy")
)
stopifnot(length(start_units) == 22L)

# Full names -----------------------------------------------------------------
full_names <- c(
  adr = "Adriatic Sea", aeg = "Aegean Sea", alb = "Albania", ank = "Ankara",
  apu = "Apulia", arm = "Armenia", bal = "Baltic Sea", bar = "Barents Sea",
  bel = "Belgium", ber = "Berlin", bla = "Black Sea", boh = "Bohemia",
  bot = "Gulf of Bothnia", bre = "Brest", bud = "Budapest", bul = "Bulgaria",
  bur = "Burgundy", cly = "Clyde", con = "Constantinople", den = "Denmark",
  eas = "Eastern Mediterranean", edi = "Edinburgh", eng = "English Channel",
  fin = "Finland", gal = "Galicia", gas = "Gascony", gre = "Greece",
  hel = "Helgoland Bight", hol = "Holland", ion = "Ionian Sea",
  iri = "Irish Sea", kie = "Kiel", lon = "London", lvn = "Livonia",
  lvp = "Liverpool", lyo = "Gulf of Lyon", mao = "Mid-Atlantic Ocean",
  mar = "Marseilles", mos = "Moscow", mun = "Munich", naf = "North Africa",
  nao = "North Atlantic Ocean", nap = "Naples", nth = "North Sea",
  nwg = "Norwegian Sea", nwy = "Norway", par = "Paris", pic = "Picardy",
  pie = "Piedmont", por = "Portugal", pru = "Prussia", rom = "Rome",
  ruh = "Ruhr", rum = "Rumania", ser = "Serbia", sev = "Sevastopol",
  sil = "Silesia", ska = "Skagerrak", smy = "Smyrna", spa = "Spain",
  stp = "St Petersburg", swe = "Sweden", syr = "Syria", tri = "Trieste",
  tun = "Tunis", tus = "Tuscany", tyr = "Tyrolia", tys = "Tyrrhenian Sea",
  ukr = "Ukraine", ven = "Venice", vie = "Vienna", wal = "Wales",
  war = "Warsaw", wes = "Western Mediterranean", yor = "Yorkshire"
)
stopifnot(setequal(names(full_names), provinces))

# Schematic map coordinates (0-100 grid, north up) ---------------------------
coord_x <- c(
  nao = 10, nwg = 30, bar = 55, stp = 62, nwy = 40, swe = 46, fin = 53,
  ska = 41, bot = 50, den = 40, bal = 48, lvn = 56, pru = 49, ber = 44,
  kie = 39, hel = 36, nth = 29, edi = 22, cly = 19, lvp = 20, yor = 24,
  wal = 19, lon = 25, iri = 14, eng = 19, bel = 31, hol = 34, ruh = 36,
  mun = 40, sil = 47, war = 54, mos = 68, ukr = 62, sev = 70, gal = 55,
  boh = 45, vie = 47, bud = 52, tri = 45, tyr = 42, ven = 41, pie = 37,
  tus = 40, rom = 42, nap = 45, apu = 47, adr = 47, alb = 51, ser = 53,
  rum = 59, bul = 58, gre = 55, aeg = 59, bla = 65, con = 62, ank = 68,
  arm = 75, smy = 66, syr = 74, eas = 66, ion = 50, tun = 42, naf = 30,
  tys = 44, wes = 34, lyo = 33, mar = 32, spa = 22, por = 14, mao = 10,
  gas = 26, bre = 23, par = 29, pic = 28, bur = 33
)
coord_y <- c(
  nao = 88, nwg = 92, bar = 97, stp = 88, nwy = 85, swe = 83, fin = 87,
  ska = 78, bot = 80, den = 75, bal = 74, lvn = 78, pru = 70, ber = 70,
  kie = 71, hel = 74, nth = 79, edi = 83, cly = 85, lvp = 79, yor = 78,
  wal = 75, lon = 74, iri = 76, eng = 70, bel = 70, hol = 73, ruh = 68,
  mun = 65, sil = 67, war = 70, mos = 76, ukr = 68, sev = 64, gal = 63,
  boh = 62, vie = 59, bud = 58, tri = 54, tyr = 59, ven = 52, pie = 52,
  tus = 48, rom = 44, nap = 39, apu = 43, adr = 48, alb = 48, ser = 52,
  rum = 57, bul = 50, gre = 42, aeg = 41, bla = 55, con = 45, ank = 48,
  arm = 48, smy = 41, syr = 39, eas = 34, ion = 34, tun = 30, naf = 28,
  tys = 38, wes = 36, lyo = 44, mar = 50, spa = 45, por = 44, mao = 55,
  gas = 53, bre = 63, par = 61, pic = 67, bur = 60
)
stopifnot(setequal(names(coord_x), provinces), setequal(names(coord_y), provinces))

coast_coord <- list(
  "bul/ec" = c(61, 52), "bul/sc" = c(58, 46),
  "spa/nc" = c(20, 53), "spa/sc" = c(24, 38),
  "stp/nc" = c(58, 93), "stp/sc" = c(57, 82)
)

# Assemble -------------------------------------------------------------------
home_of <- character(0)
for (pw in powers) for (sc in home_centres[[pw]]) home_of[sc] <- pw

province_records <- lapply(provinces, function(p) {
  list(
    code = p,
    name = unname(full_names[[p]]),
    type = unname(province_type[[p]]),
    supply_centre = p %in% supply_centres,
    home_power = if (p %in% names(home_of)) unname(home_of[[p]]) else NA_character_,
    coasts = coasts[[p]],
    x = unname(coord_x[[p]]),
    y = unname(coord_y[[p]])
  )
})

coast_records <- lapply(names(coast_coord), function(l) {
  list(loc = l, x = coast_coord[[l]][1], y = coast_coord[[l]][2])
})

map_list <- list(
  name = "standard",
  description = paste(
    "Standard seven-power Diplomacy board (pre-1914 Europe):",
    "75 provinces, 34 supply centres, 22 starting units."
  ),
  powers = powers,
  provinces = province_records,
  coast_locations = coast_records,
  army_adjacency = army_adj,
  fleet_adjacency = fleet_adj,
  supply_centres = supply_centres,
  home_centres = home_centres,
  start_units = start_units
)

# Sanity checks --------------------------------------------------------------
sym_fail <- character(0)
for (p in names(army_adj)) {
  for (q in army_adj[[p]]) {
    if (!p %in% army_adj[[q]]) sym_fail <- c(sym_fail, paste(p, "->", q))
  }
}
stopifnot(length(sym_fail) == 0L)

for (l in names(fleet_adj)) {
  for (m in fleet_adj[[l]]) {
    if (!l %in% fleet_adj[[m]]) sym_fail <- c(sym_fail, paste(l, "=>", m))
  }
}
stopifnot(length(sym_fail) == 0L)

out <- file.path("inst", "extdata", "standard_map.json")
dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
jsonlite::write_json(map_list, out, auto_unbox = TRUE, pretty = TRUE, null = "null")
message("wrote ", out, " (", length(provinces), " provinces)")
