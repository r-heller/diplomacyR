# Game record ------------------------------------------------------------------

#' Construct a game history
#'
#' @param turns A list of turn records.
#' @return An object of class `dp_history`.
#' @noRd
new_dp_history <- function(turns = list()) {
  structure(list(turns = turns), class = "dp_history")
}

#' Validate a game history
#'
#' @param x A candidate `dp_history`.
#' @param call Caller environment, for error reporting.
#' @return `x`, validated.
#' @noRd
validate_dp_history <- function(x, call = rlang::caller_env()) {
  .check_class(x, "dp_history", call = call)
  if (!is.list(x$turns)) {
    cli::cli_abort("A {.cls dp_history} must hold a list of turns.",
                   call = call)
  }
  x
}

#' Start an empty game history
#'
#' A `dp_history` records the state, the orders and the outcome of every turn
#' of a game, so that a game can be replayed, charted or analysed after the
#' fact.
#'
#' @return An empty [dp_history] object.
#' @export
#' @family analysis
#' @examples
#' dp_history()
dp_history <- function() {
  validate_dp_history(new_dp_history())
}

#' Test whether an object is a game history
#'
#' @param x An object to test.
#' @return A logical scalar.
#' @export
#' @family analysis
#' @examples
#' is_dp_history(dp_history())
is_dp_history <- function(x) inherits(x, "dp_history")

#' Append a turn to a game history
#'
#' @param history A [dp_history] object.
#' @param game The game state before the turn.
#' @param orders The orders submitted for the turn.
#' @param result The [dp_result] the turn produced.
#' @return The history with one more turn.
#' @export
#' @family analysis
#' @examples
#' g <- dp_new_game()
#' res <- dp_adjudicate(g, dp_example_orders())
#' dp_history_append(dp_history(), g, dp_example_orders(), res)
dp_history_append <- function(history, game, orders, result) {
  .check_class(history, "dp_history")
  .check_game(game)
  .check_class(result, "dp_result")
  counts <- dp_power_counts(game)
  turn <- list(
    season = game$season,
    year = game$year,
    phase = game$phase,
    units = game$units,
    sc_owner = game$sc_owner,
    counts = counts,
    orders = orders,
    result = result
  )
  history$turns <- c(history$turns, list(turn))
  history
}

#' Number of turns recorded
#'
#' @param x A [dp_history] object.
#' @return An integer scalar.
#' @export
#' @examples
#' length(dp_history())
length.dp_history <- function(x) length(x$turns)

#' Coerce a game history to a tibble
#'
#' @param x A [dp_history] object.
#' @param ... Ignored.
#' @return A tibble with one row per power per turn and columns `turn`,
#'   `season`, `year`, `phase`, `power`, `centres` and `units`.
#' @export
#' @family analysis
#' @examples
#' g <- dp_new_game()
#' res <- dp_adjudicate(g, dp_example_orders())
#' h <- dp_history_append(dp_history(), g, dp_example_orders(), res)
#' as_tibble(h)
as_tibble.dp_history <- function(x, ...) {
  rlang::check_dots_empty()
  if (length(x$turns) == 0L) {
    return(tibble::tibble(
      turn = integer(0), season = character(0), year = integer(0),
      phase = character(0), power = character(0), centres = integer(0),
      units = integer(0)
    ))
  }
  parts <- lapply(seq_along(x$turns), function(i) {
    tn <- x$turns[[i]]
    tibble::tibble(
      turn = i,
      season = tn$season,
      year = tn$year,
      phase = tn$phase,
      power = tn$counts$power,
      centres = tn$counts$centres,
      units = tn$counts$units
    )
  })
  do.call(rbind, parts)
}

#' Coerce orders to a tibble
#'
#' @param x A `dp_orders` object.
#' @param ... Ignored.
#' @return A plain tibble with the order columns.
#' @export
#' @family orders
#' @examples
#' as_tibble(dp_example_orders())
as_tibble.dp_orders <- function(x, ...) {
  rlang::check_dots_empty()
  tibble::new_tibble(unclass(x), nrow = nrow(x))
}

#' @importFrom tibble as_tibble
#' @export
tibble::as_tibble
