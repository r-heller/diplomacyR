# diplomacyR — Reference Stub Files

These illustrate the intended architecture. The build prompt fleshes them out.

## R/diplomacyR-package.R
```r
#' @keywords internal
"_PACKAGE"

#' @importFrom rlang .data %||%
#' @importFrom tibble tibble
## usethis namespace: start
## usethis namespace: end
NULL
```

## R/game.R  (constructor / validator / helper pattern)
```r
# --- low-level constructor: trusted input, no validation ---
new_dp_game <- function(map, units, sc_owner, season, year, phase,
                        powers, status = list()) {
  stopifnot(inherits(map, "dp_map"))
  structure(
    list(map = map, units = units, sc_owner = sc_owner,
         season = season, year = year, phase = phase,
         powers = powers, status = status),
    class = "dp_game"
  )
}

# --- validator: checks invariants ---
validate_dp_game <- function(x, call = rlang::caller_env()) {
  # one unit per province; SC ownership consistent; phase in known set; etc.
  x
}

#' Create a new standard Diplomacy game
#'
#' Initialises a game in Spring 1901 with the canonical starting position:
#' 22 units across the seven Great Powers on the standard map.
#'
#' @param map A [dp_map] object. Defaults to the standard map via [dp_map()].
#' @param year Starting year. Default `1901`.
#' @return A [dp_game] object in the Spring 1901 movement phase.
#' @examples
#' g <- dp_new_game()
#' g
#' @export
dp_new_game <- function(map = dp_map("standard"), year = 1901) {
  # place starting units + home SC ownership, then:
  # validate_dp_game(new_dp_game(...))
}

#' @export
print.dp_game <- function(x, ...) {
  rlang::check_dots_empty()
  cli::cli_text("{.cls dp_game} {x$season} {x$year} ({x$phase} phase)")
  # per-power SC count + unit count summary
  invisible(x)
}
```

## R/order.R  (order representation)
```r
#' Construct a Diplomacy order
#'
#' @param power One of the seven powers (e.g. `"France"`).
#' @param type One of `"hold"`, `"move"`, `"support"`, `"convoy"`,
#'   `"retreat"`, `"build"`, `"disband"`.
#' @param unit Province code of the ordered unit (e.g. `"par"`), with unit
#'   type inferred from the board, or explicit via `unit_type`.
#' @param target Destination/target province, or `NULL` for holds.
#' @param aux For support/convoy: the order being supported/convoyed.
#' @param call Caller environment for error reporting.
#' @return A one-row `dp_orders` tibble.
#' @export
dp_order <- function(power, type, unit, target = NULL, aux = NULL,
                     call = rlang::caller_env()) {
  type <- rlang::arg_match(type,
    c("hold","move","support","convoy","retreat","build","disband"))
  # validate + return type-stable 1-row dp_orders tibble
}
```

## R/adjudicate.R  (engine entry — the hard part)
```r
#' Adjudicate a movement phase
#'
#' Resolves all submitted orders simultaneously according to the standard
#' Diplomacy rules: support counting, support cutting, convoy resolution
#' (including the convoy paradox cases), standoffs, dislodgement, and the
#' self-dislodgement / self-standoff prohibitions. Implementation follows the
#' Diplomacy Adjudicator Test Cases (DATC) section 6.
#'
#' @param game A [dp_game] in a movement phase.
#' @param orders A `dp_orders` tibble with one order per unit. Units without
#'   an explicit order are treated as holding.
#' @param call Caller environment for error reporting.
#' @return A [dp_result] object recording, per order, whether it succeeded,
#'   plus the set of dislodged units and bounced provinces. Retrieve the next
#'   game state with [dp_advance()].
#' @examples
#' g <- dp_new_game()
#' o <- dp_example_orders("spring_1901")
#' res <- dp_adjudicate(g, o)
#' res
#' @export
dp_adjudicate <- function(game, orders, call = rlang::caller_env()) {
  # 1. parse + legalise orders (illegal -> hold)
  # 2. resolve convoy paths (adjudicate-convoy.R)
  # 3. compute support strengths, apply support cuts (adjudicate-support.R)
  # 4. resolve moves/standoffs/dislodgements (adjudicate-dislodge.R)
  # 5. return dp_result
}
```

## R/ai.R  (bot dispatch)
```r
#' Generate orders for a power using a bot
#'
#' @param game A [dp_game] object.
#' @param power The power to generate orders for.
#' @param bot Bot strategy: `"random"`, `"hold"`, `"greedy"`, or
#'   `"negotiator"`.
#' @param ... Passed to the specific bot.
#' @return A `dp_orders` tibble of legal orders for `power`.
#' @export
dp_ai_orders <- function(game, power, bot = "greedy", ...) {
  bot <- rlang::arg_match(bot, c("random","hold","greedy","negotiator"))
  switch(bot,
    random     = .ai_random(game, power, ...),
    hold       = .ai_hold(game, power, ...),
    greedy     = .ai_greedy(game, power, ...),
    negotiator = .ai_negotiator(game, power, ...)
  )
}
```

## R/simulate.R  (batch)
```r
#' Simulate many Diplomacy games
#'
#' Plays `n` games to completion (solo victory or turn cap / draw) with the
#' given bot assignment, returning aggregate statistics.
#'
#' @param n Number of games.
#' @param bots Named character vector mapping power -> bot, or a single bot
#'   name applied to all powers.
#' @param max_years Turn cap before declaring a draw. Default `20`.
#' @param seed Optional RNG seed for reproducibility.
#' @param verbose Show a progress bar. Default `TRUE`.
#' @return A [dp_sim] object; [dp_stats()] and the `dp_plot_*` functions
#'   summarise it.
#' @examples
#' \donttest{
#' sim <- dp_simulate(n = 10, bots = "greedy", max_years = 5)
#' dp_stats(sim)
#' }
#' @export
dp_simulate <- function(n = 100, bots = "greedy", max_years = 20,
                        seed = NULL, verbose = TRUE) {
  # loop dp_play(); collect per-game outcome; return dp_sim
}
```

## tests/testthat/helper-datc.R  (compliance harness)
```r
# Loads DATC cases from inst/extdata/datc/ and runs each through
# dp_adjudicate(), asserting the resolved outcome matches the expected result.
datc_cases <- function(section = NULL) {
  path <- system.file("extdata", "datc", package = "diplomacyR")
  # read JSON, optionally filter by section (e.g. "6.C")
}

expect_datc <- function(case) {
  g <- .datc_setup(case)                    # build board state from case
  res <- dp_adjudicate(g, .datc_orders(case))
  testthat::expect_equal(.datc_outcome(res), case$expected, info = case$id)
}
```
