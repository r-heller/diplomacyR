# Internal helpers ------------------------------------------------------------

#' @importFrom rlang %||%
#' @export
rlang::`%||%`

#' Check that a value is a single string
#'
#' @param x Value to check.
#' @param arg Name of the argument being checked.
#' @param call Caller environment, for error reporting.
#' @return `x`, invisibly, if valid; otherwise an error is thrown.
#' @noRd
.check_string <- function(x, arg = rlang::caller_arg(x),
                          call = rlang::caller_env()) {
  if (!is.character(x) || length(x) != 1L || is.na(x)) {
    cli::cli_abort(
      "{.arg {arg}} must be a single string, not {.obj_type_friendly {x}}.",
      call = call
    )
  }
  invisible(x)
}

#' Check that a value is a single `TRUE`/`FALSE`
#'
#' @inheritParams .check_string
#' @return `x`, invisibly, if valid; otherwise an error is thrown.
#' @noRd
.check_flag <- function(x, arg = rlang::caller_arg(x),
                        call = rlang::caller_env()) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    cli::cli_abort(
      "{.arg {arg}} must be {.val {TRUE}} or {.val {FALSE}}.",
      call = call
    )
  }
  invisible(x)
}

#' Check that a value is a single non-negative whole number
#'
#' @inheritParams .check_string
#' @param min Smallest allowed value.
#' @return `x` coerced to integer, if valid; otherwise an error is thrown.
#' @noRd
.check_count <- function(x, min = 0L, arg = rlang::caller_arg(x),
                         call = rlang::caller_env()) {
  if (!is.numeric(x) || length(x) != 1L || !is.finite(x) || x != trunc(x) ||
      x < min || x > .Machine$integer.max) {
    cli::cli_abort(
      "{.arg {arg}} must be a single whole number of at least {.val {min}}.",
      call = call
    )
  }
  as.integer(x)
}

#' Check that an object inherits from a class
#'
#' @inheritParams .check_string
#' @param cls Required class.
#' @return `x`, invisibly, if valid; otherwise an error is thrown.
#' @noRd
.check_class <- function(x, cls, arg = rlang::caller_arg(x),
                         call = rlang::caller_env()) {
  if (!inherits(x, cls)) {
    cli::cli_abort(
      "{.arg {arg}} must be a {.cls {cls}} object, not \\
       {.obj_type_friendly {x}}.",
      call = call
    )
  }
  invisible(x)
}

#' Check that an object is a game
#'
#' @inheritParams .check_string
#' @return `x`, invisibly, if valid; otherwise an error is thrown.
#' @noRd
.check_game <- function(x, arg = rlang::caller_arg(x),
                        call = rlang::caller_env()) {
  .check_class(x, "dp_game", arg = arg, call = call)
}

#' Province code of a location
#'
#' Strips a coast qualifier: `"spa/nc"` becomes `"spa"`.
#'
#' @param x Character vector of locations.
#' @return A character vector of province codes.
#' @noRd
.province <- function(x) sub("/.*$", "", x)

#' Coast qualifier of a location
#'
#' @param x Character vector of locations.
#' @return A character vector of coast codes, `NA` where absent.
#' @noRd
.coast <- function(x) {
  out <- rep(NA_character_, length(x))
  has <- grepl("/", x, fixed = TRUE)
  out[has] <- sub("^.*/", "", x[has])
  out
}

#' Title-case a location code for display
#'
#' @param x Character vector of locations.
#' @return A character vector such as `"Par"` or `"Spa/nc"`.
#' @noRd
.fmt_loc <- function(x) {
  p <- .province(x)
  cst <- .coast(x)
  out <- paste0(toupper(substr(p, 1L, 1L)), substr(p, 2L, nchar(p)))
  ifelse(is.na(cst), out, paste0(out, "/", cst))
}

#' Abbreviate a unit type for display
#'
#' @param x Character vector of `"army"` / `"fleet"`.
#' @return A character vector of `"A"` / `"F"`.
#' @noRd
.fmt_unit <- function(x) ifelse(x == "army", "A", "F")

#' Powers of the standard game
#'
#' @return A character vector of the seven Great Powers.
#' @noRd
.dp_powers <- function() {
  c("Austria", "England", "France", "Germany", "Italy", "Russia", "Turkey")
}

#' Match a user-supplied power name to a canonical power
#'
#' @param x Character vector of power names or abbreviations.
#' @param powers Allowed powers.
#' @param call Caller environment, for error reporting.
#' @return A character vector of canonical power names.
#' @noRd
.match_power <- function(x, powers = .dp_powers(), call = rlang::caller_env()) {
  idx <- pmatch(tolower(x), tolower(powers), duplicates.ok = TRUE)
  if (anyNA(idx)) {
    bad <- x[is.na(idx)]
    cli::cli_abort(
      c("Unknown power{?s}: {.val {bad}}.",
        i = "Powers are {.val {powers}}."),
      call = call
    )
  }
  powers[idx]
}

#' An empty orders tibble with the canonical columns
#'
#' @return A zero-row `dp_orders` tibble.
#' @noRd
.empty_orders <- function() {
  new_dp_orders(tibble::tibble(
    power = character(0),
    type = character(0),
    unit_type = character(0),
    loc = character(0),
    target = character(0),
    aux_type = character(0),
    aux_loc = character(0),
    aux_target = character(0),
    via_convoy = logical(0)
  ))
}

#' An empty units tibble
#'
#' @return A zero-row tibble with columns `power`, `type`, `loc`.
#' @noRd
.empty_units <- function() {
  tibble::tibble(
    power = character(0),
    type = character(0),
    loc = character(0)
  )
}

#' An empty dislodged-units tibble
#'
#' @return A zero-row tibble with columns `power`, `type`, `loc`, `from` and
#'   `by_convoy`.
#' @noRd
.empty_dislodged <- function() {
  tibble::tibble(
    power = character(0),
    type = character(0),
    loc = character(0),
    from = character(0),
    by_convoy = logical(0)
  )
}

.restore_seed <- function(seed) {
  if (is.null(seed)) {
    if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE))
      rm(".Random.seed", envir = .GlobalEnv)
  } else assign(".Random.seed", seed, envir = .GlobalEnv)
}
