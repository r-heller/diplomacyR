# Order notation ---------------------------------------------------------------

.loc_rx <- "[a-z]{3}(?:/[a-z]{2})?"

#' Replace full province names with their three-letter codes
#'
#' @param x A character vector of order text, already lower-cased.
#' @param map A [dp_map] object.
#' @return `x` with full names replaced by codes.
#' @noRd
.expand_names <- function(x, map) {
  nm <- tolower(map$provinces$name)
  code <- map$provinces$code
  ord <- order(nchar(nm), decreasing = TRUE)
  for (i in ord) {
    if (nm[i] == code[i]) next
    x <- gsub(paste0("\\b", nm[i], "\\b"), code[i], x, perl = TRUE)
  }
  x
}

#' Normalise a raw order string
#'
#' @param x A character vector of order text.
#' @param map A [dp_map] object.
#' @return A lower-cased, whitespace-normalised character vector.
#' @noRd
.normalise_order_text <- function(x, map) {
  x <- sub("#.*$", "", x)
  x <- tolower(trimws(x))
  x <- gsub("[\u2010-\u2015\u2212]", "-", x)
  x <- gsub("->", "-", x, fixed = TRUE)
  x <- gsub("([a-z]{3})\\s*\\(\\s*([ns]?[ew]?c)\\s*\\)", "\\1/\\2", x)
  x <- gsub("\\s*/\\s*", "/", x)
  x <- .expand_names(x, map)
  x <- gsub("-", " - ", x, fixed = TRUE)
  x <- gsub("\\s+", " ", x)
  trimws(x)
}

#' Parse Diplomacy order notation
#'
#' Reads orders written in standard notation and returns them as a
#' `dp_orders` tibble. All the usual spellings are accepted, in any case:
#'
#' * `"A Par - Bur"`, `"A Par-Bur"`, `"A Paris to Burgundy"` (move)
#' * `"A Bur H"`, `"A Bur holds"` (hold)
#' * `"F Lon S A Wal - Yor"`, `"F Lon supports A Wal"` (support)
#' * `"F Nth C A Lon - Nwy"` (convoy)
#' * `"A Lon - Bel via convoy"` (explicitly convoyed move)
#' * `"A Tri R Alb"` (retreat), `"Build A Par"`, `"Remove F Bre"`, `"Waive"`
#'
#' Each element may be prefixed with the ordering power, as in
#' `"France: A Par - Bur"`. Otherwise `power` supplies it.
#'
#' @param x A character vector of orders, one per element. Multi-line strings
#'   are split on newlines and semicolons.
#' @param power Default power for orders that do not name one.
#' @param phase Phase the orders belong to: `"movement"`, `"retreat"` or
#'   `"build"`. A bare `"A Tri - Alb"` is a move in a movement phase and a
#'   retreat in a retreat phase.
#' @param map A [dp_map] object used to validate province codes.
#' @param call Caller environment, for error reporting. Experts only.
#' @return A `dp_orders` tibble with one row per order.
#' @export
#' @family orders
#' @examples
#' dp_parse_orders(c("France: A Par - Bur", "France: A Mar S A Par - Bur"))
#' dp_parse_orders("F Nth C A Lon - Nwy", power = "England")
dp_parse_orders <- function(x, power = NULL, phase = c("movement", "retreat",
                                                       "build"),
                            map = dp_map(), call = rlang::caller_env()) {
  .check_class(map, "dp_map", call = call)
  phase <- rlang::arg_match(phase, error_call = call)
  if (!is.character(x)) {
    cli::cli_abort("{.arg x} must be a character vector.", call = call)
  }
  x <- unlist(strsplit(x, "[\n;]"), use.names = FALSE)
  x <- x[nzchar(trimws(sub("#.*$", "", x)))]
  if (length(x) == 0L) return(.empty_orders())

  rows <- lapply(x, function(line) {
    .parse_one_order(line, power = power, phase = phase, map = map,
                     call = call)
  })
  new_dp_orders(do.call(rbind, rows))
}

#' Parse a single order string
#'
#' @param line One order, optionally prefixed with `"Power:"`.
#' @param power Default power.
#' @param phase Phase the order belongs to.
#' @param map A [dp_map] object.
#' @param call Caller environment, for error reporting.
#' @return A one-row tibble with the canonical order columns.
#' @noRd
.parse_one_order <- function(line, power, phase, map,
                             call = rlang::caller_env()) {
  original <- trimws(sub("#.*$", "", line))
  pw <- power
  if (grepl(":", original, fixed = TRUE)) {
    pw <- trimws(sub(":.*$", "", original))
    original <- trimws(sub("^[^:]*:", "", original))
  }
  if (is.null(pw)) {
    cli::cli_abort(
      c("No power given for order {.val {original}}.",
        i = "Prefix the order with {.code Power:} or set {.arg power}."),
      call = call
    )
  }
  pw <- .match_power(pw, map$powers, call = call)

  txt <- .normalise_order_text(original, map)
  via <- grepl("\\b(via|by)\\s+convoy\\b", txt)
  txt <- trimws(gsub("\\b(via|by)\\s+convoy\\b", "", txt))
  txt <- trimws(gsub("\\bconvoy\\s*$", "", txt))
  if (via) txt <- trimws(txt)

  mk <- function(type, unit_type = NA_character_, loc = NA_character_,
                 target = NA_character_, aux_type = NA_character_,
                 aux_loc = NA_character_, aux_target = NA_character_,
                 via_convoy = FALSE) {
    tibble::tibble(
      power = pw, type = type, unit_type = unit_type, loc = loc,
      target = target, aux_type = aux_type, aux_loc = aux_loc,
      aux_target = aux_target, via_convoy = via_convoy
    )
  }
  ut <- function(tok) {
    if (is.na(tok) || !nzchar(tok)) return(NA_character_)
    if (substr(tok, 1L, 1L) == "a") "army" else "fleet"
  }
  chk <- function(loc, what) {
    if (is.na(loc)) return(loc)
    if (!.province(loc) %in% map$provinces$code) {
      cli::cli_abort(
        c("Could not parse the order {.val {original}}.",
          x = "{what} {.val {loc}} is not a province on this board."),
        call = call
      )
    }
    loc
  }

  if (grepl("^waive", txt)) return(mk("waive"))

  m <- regmatches(txt, regexec(
    paste0("^build\\s+(a|f|army|fleet)\\s+(", .loc_rx, ")$"), txt
  ))[[1]]
  if (length(m) > 0L) {
    return(mk("build", unit_type = ut(m[2]), loc = chk(m[3], "Build site")))
  }
  m <- regmatches(txt, regexec(
    paste0("^(remove|disband)\\s+(?:(a|f|army|fleet)\\s+)?(", .loc_rx, ")$"),
    txt
  ))[[1]]
  if (length(m) > 0L) {
    return(mk("disband", unit_type = ut(m[3]), loc = chk(m[4], "Unit")))
  }

  m <- regmatches(txt, regexec(
    paste0("^(?:(a|f|army|fleet)\\s+)?(", .loc_rx, ")\\s*(.*)$"), txt
  ))[[1]]
  if (length(m) == 0L) {
    cli::cli_abort(
      c("Could not parse the order {.val {original}}.",
        i = "Orders look like {.val A Par - Bur} or {.val F Lon S A Wal}."),
      call = call
    )
  }
  unit_type <- ut(m[2])
  loc <- chk(m[3], "Unit location")
  rest <- trimws(m[4])

  if (!nzchar(rest) || grepl("^(h|hold|holds|stand|stands)$", rest)) {
    if (phase == "build") {
      return(mk("disband", unit_type = unit_type, loc = loc))
    }
    return(mk("hold", unit_type = unit_type, loc = loc))
  }
  if (grepl("^(b|build)$", rest)) {
    return(mk("build", unit_type = unit_type, loc = loc))
  }
  if (grepl("^(d|disband|remove)$", rest)) {
    return(mk("disband", unit_type = unit_type, loc = loc))
  }

  m <- regmatches(rest, regexec(
    paste0("^(?:-|to|r|retreat|retreats)\\s+(", .loc_rx, ")$"), rest
  ))[[1]]
  if (length(m) > 0L) {
    explicit_retreat <- grepl("^(r|retreat|retreats)\\b", rest)
    type <- if (explicit_retreat || phase == "retreat") "retreat" else "move"
    return(mk(type, unit_type = unit_type, loc = loc,
              target = chk(m[2], "Destination"), via_convoy = via))
  }

  m <- regmatches(rest, regexec(
    paste0("^(?:s|sup|supp|support|supports)\\s+(?:(a|f|army|fleet)\\s+)?(",
           .loc_rx, ")(?:\\s+-\\s+(", .loc_rx, "))?$"),
    rest
  ))[[1]]
  if (length(m) > 0L) {
    return(mk("support", unit_type = unit_type, loc = loc,
              aux_type = ut(m[2]), aux_loc = chk(m[3], "Supported unit"),
              aux_target = chk(if (nzchar(m[4])) m[4] else NA_character_,
                               "Support destination")))
  }

  m <- regmatches(rest, regexec(
    paste0("^(?:c|conv|convoy|convoys)\\s+(?:(a|f|army|fleet)\\s+)?(",
           .loc_rx, ")\\s+-\\s+(", .loc_rx, ")$"),
    rest
  ))[[1]]
  if (length(m) > 0L) {
    return(mk("convoy", unit_type = unit_type, loc = loc,
              aux_type = ut(m[2]), aux_loc = chk(m[3], "Convoyed unit"),
              aux_target = chk(m[4], "Convoy destination")))
  }

  cli::cli_abort(
    c("Could not parse the order {.val {original}}.",
      x = "{.val {rest}} is not a recognised order verb.",
      i = "Use {.val -} (move), {.val H}, {.val S}, {.val C}, {.val R}, \\
           {.val Build} or {.val Remove}."),
    call = call
  )
}

#' Render orders as standard notation
#'
#' @param x A `dp_orders` tibble.
#' @param ... Ignored.
#' @return A character vector, one canonical order string per row.
#' @export
#' @family orders
#' @examples
#' format(dp_parse_orders("France: A Par - Bur"))
format.dp_orders <- function(x, ...) {
  if (nrow(x) == 0L) return(character(0))
  unit <- ifelse(is.na(x$unit_type), "", paste0(.fmt_unit(x$unit_type), " "))
  aux_unit <- ifelse(is.na(x$aux_type), "",
                     paste0(.fmt_unit(x$aux_type), " "))
  loc <- .fmt_loc(x$loc)
  tgt <- .fmt_loc(x$target)
  aux <- .fmt_loc(x$aux_loc)
  aux_t <- .fmt_loc(x$aux_target)

  out <- character(nrow(x))
  for (i in seq_len(nrow(x))) {
    out[i] <- switch(x$type[i],
      hold = paste0(unit[i], loc[i], " H"),
      move = paste0(unit[i], loc[i], " - ", tgt[i],
                    if (isTRUE(x$via_convoy[i])) " via Convoy" else ""),
      retreat = paste0(unit[i], loc[i], " R ", tgt[i]),
      support = paste0(
        unit[i], loc[i], " S ", aux_unit[i], aux[i],
        if (is.na(x$aux_target[i])) "" else paste0(" - ", aux_t[i])
      ),
      convoy = paste0(unit[i], loc[i], " C ", aux_unit[i], aux[i], " - ",
                      aux_t[i]),
      build = paste0("Build ", unit[i], loc[i]),
      disband = paste0("Remove ", unit[i], loc[i]),
      waive = "Waive"
    )
  }
  paste0(x$power, ": ", out)
}

#' @export
as.character.dp_orders <- function(x, ...) format(x, ...)
