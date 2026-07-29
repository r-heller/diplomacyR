# data-raw/datc_cases.R -------------------------------------------------------
#
# Converts the machine-readable DATC (Diplomacy Adjudicator Test Cases,
# version 2.4, section 6) into the structured JSON consumed by
# tests/testthat/test-datc.R.
#
# The DATC is the work of Lucas B. Kruijswijk and is the community standard
# conformance suite for Diplomacy adjudicators. Expected outcomes below are
# taken verbatim from that suite -- they are never derived from this package's
# own behaviour.
#
# Input:  data-raw/datc_v2.4_06.txt
# Output: inst/extdata/datc/datc_6a_6g.json   (movement phase)
#         inst/extdata/datc/datc_6h_6j.json   (retreat and adjustment phases)
#
# Run with:  source("data-raw/datc_cases.R")

src <- file.path("data-raw", "datc_v2.4_06.txt")
stopifnot(file.exists(src))
raw <- readLines(src, warn = FALSE)

# The source uses a handful of alternative province abbreviations.
alias <- c(gol = "lyo", mid = "mao", nat = "nao", nrg = "nwg")

fix_alias <- function(x) {
  for (a in names(alias)) {
    x <- gsub(paste0("\\b", a, "\\b"), alias[[a]], x)
  }
  x
}

# A `###` prefix marks a dislodged unit with no retreat available; the unit is
# still dislodged, so the marker is dropped before comments are stripped.
strip_comment <- function(x) {
  x <- sub("^(\\s*)###\\s*", "\\1", x)
  trimws(sub("#.*$", "", x))
}

# The source carries one misspelt power name.
fix_power <- function(x) sub("^Germnay$", "Germany", x)

sections <- c(
  "CASE", "PRESTATE_SETPHASE", "PRESTATE", "PRESTATE_DISLODGED",
  "PRESTATE_RESULTS", "PRESTATE_SUPPLYCENTER_OWNERS", "ORDERS",
  "POSTSTATE", "POSTSTATE_DISLODGED", "POSTSTATE_SAME", "END",
  "VARIANT_ALL"
)

split_entry <- function(x) {
  # A few state lines omit the colon after the power name.
  if (!grepl(":", x, fixed = TRUE)) x <- sub("\\s+", ": ", trimws(x))
  pw <- fix_power(trimws(sub(":.*$", "", x)))
  body <- trimws(sub("^[^:]*:", "", x))
  list(power = pw, body = fix_alias(tolower(body)), raw = body)
}

is_unit_spec <- function(entry) {
  grepl("^[af]\\s+[a-z]{3}(/[a-z]{2})?$", entry$body)
}

parse_unit <- function(entry) {
  bits <- strsplit(entry$body, "\\s+")[[1]]
  type <- if (toupper(bits[1]) == "A") "army" else "fleet"
  list(power = entry$power, type = type, loc = bits[2])
}

cases <- list()
cur <- NULL
mode <- NULL
desc_buf <- character(0)

flush_case <- function(cur) {
  if (is.null(cur)) return(NULL)
  if (isTRUE(cur$poststate_same)) cur$poststate <- cur$prestate
  cur$poststate_same <- NULL
  cur
}

for (ln in raw) {
  bare <- strip_comment(ln)
  if (!nzchar(bare)) {
    if (grepl("^#", trimws(ln)) && is.null(cur)) {
      txt <- trimws(sub("^#+", "", trimws(ln)))
      if (nzchar(txt) && !grepl("^[-=#]+$", txt)) desc_buf <- c(desc_buf, txt)
    } else if (!grepl("^#", trimws(ln))) {
      desc_buf <- character(0)
    }
    next
  }
  key <- strsplit(bare, "\\s+")[[1]][1]
  if (key %in% sections) {
    mode <- key
    if (key == "CASE") {
      cases[[length(cases) + 1L]] <- flush_case(cur)
      id <- trimws(sub("^CASE\\s+", "", bare))
      id <- strsplit(id, "\\s+")[[1]][1]
      cur <- list(
        id = id,
        section = sub("^(6\\.[A-J]).*$", "\\1", id),
        description = paste(utils::tail(desc_buf, 3L), collapse = " "),
        phase = "Movement",
        prestate = list(), prestate_dislodged = list(),
        prestate_results = list(),
        sc_owners = list(), orders = character(0),
        poststate = list(), poststate_dislodged = list(),
        poststate_same = FALSE
      )
      desc_buf <- character(0)
      next
    }
    if (key == "PRESTATE_SETPHASE") {
      ph <- trimws(sub("^PRESTATE_SETPHASE\\s+", "", bare))
      cur$phase <- trimws(sub("^.*,\\s*", "", ph))
      next
    }
    if (key == "POSTSTATE_SAME") {
      cur$poststate_same <- TRUE
      next
    }
    if (key == "END") {
      cases[[length(cases) + 1L]] <- flush_case(cur)
      cur <- NULL
      mode <- NULL
      desc_buf <- character(0)
      next
    }
    next
  }
  if (is.null(cur) || is.null(mode)) next
  entry <- split_entry(bare)
  switch(mode,
    PRESTATE = {
      if (is_unit_spec(entry)) {
        cur$prestate[[length(cur$prestate) + 1L]] <- parse_unit(entry)
      }
    },
    PRESTATE_DISLODGED = {
      if (is_unit_spec(entry)) {
        cur$prestate_dislodged[[length(cur$prestate_dislodged) + 1L]] <-
          parse_unit(entry)
      }
    },
    PRESTATE_SUPPLYCENTER_OWNERS = {
      if (!is_unit_spec(entry)) next
      u <- parse_unit(entry)
      cur$sc_owners[[length(cur$sc_owners) + 1L]] <-
        list(power = u$power, centre = u$loc)
    },
    PRESTATE_RESULTS = {
      # "SUCCESS: France: A par-bur" -- the outcome of the movement phase that
      # produced this retreat position. The harness reads the dislodging move
      # and the standoffs out of these lines.
      body <- entry$raw
      flag <- toupper(entry$power)
      cur_pw <- trimws(sub(":.*$", "", body))
      cur_ord <- trimws(sub("^[^:]*:", "", body))
      cur$prestate_results[[length(cur$prestate_results) + 1L]] <- list(
        success = identical(flag, "SUCCESS"),
        power = fix_power(cur_pw),
        order = fix_alias(tolower(cur_ord))
      )
    },
    ORDERS = {
      cur$orders <- c(cur$orders, paste0(entry$power, ": ", entry$body))
    },
    POSTSTATE = {
      if (is_unit_spec(entry)) {
        cur$poststate[[length(cur$poststate) + 1L]] <- parse_unit(entry)
      }
    },
    POSTSTATE_DISLODGED = {
      if (is_unit_spec(entry)) {
        cur$poststate_dislodged[[length(cur$poststate_dislodged) + 1L]] <-
          parse_unit(entry)
      }
    }
  )
}
cases[[length(cases) + 1L]] <- flush_case(cur)
cases <- Filter(Negate(is.null), cases)

# Deduplicate: a couple of ids appear with variant suffixes; keep all, but the
# id must be unique for reporting.
ids <- make.unique(vapply(cases, function(x) x$id, character(1)), sep = ".v")
for (i in seq_along(cases)) cases[[i]]$id <- ids[[i]]
stopifnot(!anyDuplicated(ids))

split_by <- vapply(cases, function(x) x$section, character(1))
move_cases <- cases[split_by %in% c("6.A", "6.B", "6.C", "6.D", "6.E", "6.F", "6.G")]
other_cases <- cases[split_by %in% c("6.H", "6.I", "6.J")]

meta <- list(
  source = "Diplomacy Adjudicator Test Cases (DATC), version 2.4, section 6",
  author = "Lucas B. Kruijswijk",
  note = paste(
    "Expected outcomes are taken from the DATC and are fixed by the rules of",
    "the game; they are not derived from this package's output."
  )
)

dir.create(file.path("inst", "extdata", "datc"), recursive = TRUE,
           showWarnings = FALSE)

jsonlite::write_json(
  list(meta = meta, cases = move_cases),
  file.path("inst", "extdata", "datc", "datc_6a_6g.json"),
  auto_unbox = TRUE, pretty = TRUE, null = "null"
)
jsonlite::write_json(
  list(meta = meta, cases = other_cases),
  file.path("inst", "extdata", "datc", "datc_6h_6j.json"),
  auto_unbox = TRUE, pretty = TRUE, null = "null"
)

message("wrote ", length(move_cases), " movement cases and ",
        length(other_cases), " retreat/adjustment cases")
