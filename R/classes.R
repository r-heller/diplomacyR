# Class documentation ----------------------------------------------------------
#
# The six S3 classes of the package. Each has a low-level constructor
# (`new_dp_*()`), a validator (`validate_dp_*()`) and a user-facing helper; only
# the helper is exported. These pages document the objects themselves so that
# the rest of the manual can link to them.

#' The game state
#'
#' A `dp_game` is one position on the board at one moment: who has what where,
#' who owns which supply centres, and which phase of which year it is. Build one
#' with [dp_new_game()], [dp_game_from_units()] or [dp_example_game()], and step
#' it forward with [dp_step()] or [dp_advance()].
#'
#' A `dp_game` is a list with these elements:
#'
#' \describe{
#'   \item{`map`}{The [dp_map] the game is played on.}
#'   \item{`units`}{A tibble of the units on the board, with columns `power`,
#'     `type` (`"army"` or `"fleet"`) and `loc`. Fleets on a split-coast
#'     province carry the coast, as in `"stp/sc"`.}
#'   \item{`sc_owner`}{A named character vector mapping supply centre to the
#'     power that owns it.}
#'   \item{`season`}{`"Spring"`, `"Fall"` or `"Winter"`.}
#'   \item{`year`}{The game year, an integer.}
#'   \item{`phase`}{`"movement"`, `"retreat"` or `"build"`.}
#'   \item{`powers`}{The powers in the game.}
#'   \item{`dislodged`}{A tibble of units awaiting a retreat, with columns
#'     `power`, `type`, `loc`, `from` (the province the attack came from) and
#'     `by_convoy`.}
#'   \item{`contested`}{Provinces left empty by a standoff, which are closed to
#'     retreats.}
#'   \item{`status`}{A list recording the `winner`, the `outcome` and whether
#'     the game is `over`.}
#' }
#'
#' @name dp_game
#' @family setup
#' @seealso [dp_new_game()], [dp_game_from_units()], [is_dp_game()]
#' @examples
#' g <- dp_new_game()
#' g$season
#' head(g$units)
NULL

#' The board
#'
#' A `dp_map` is the province graph a game is played on, loaded with [dp_map()].
#' It holds the province table, separate adjacency graphs for armies and for
#' fleets, the supply centres and home centres, and the canonical opening
#' position. The two graphs are what makes coasts work: armies move over
#' provinces, fleets move over coasts, and a split-coast province such as Spain
#' appears in the fleet graph only as `"spa/nc"` and `"spa/sc"`.
#'
#' @name dp_map-class
#' @family setup
#' @seealso [dp_map()], [dp_provinces()], [dp_adjacent()]
#' @examples
#' m <- dp_map()
#' m$provinces[1:3, ]
#' m$fleet_adj[["spa/nc"]]
NULL

#' A set of orders
#'
#' A `dp_orders` object is a tibble with one row per order, subclassed so that
#' [format()] renders it back to standard notation. Build one with
#' [dp_order()], [dp_parse_orders()] or [dp_legal_orders()].
#'
#' The columns are `power`, `type` (one of `"hold"`, `"move"`, `"support"`,
#' `"convoy"`, `"retreat"`, `"build"`, `"disband"`, `"waive"`), `unit_type`,
#' `loc`, `target`, `aux_type`, `aux_loc`, `aux_target` and `via_convoy`. The
#' `aux_*` columns describe the order being supported or convoyed. After
#' adjudication the tibble gains a `success` column and a `note` explaining
#' anything the rules changed.
#'
#' @name dp_orders
#' @family orders
#' @seealso [dp_order()], [dp_parse_orders()], [format.dp_orders()]
#' @examples
#' o <- dp_parse_orders("France: A Par - Bur")
#' names(o)
NULL

#' The outcome of a phase
#'
#' A `dp_result` records what a phase did. [dp_adjudicate()], [dp_retreat()]
#' and [dp_build()] all return one, and [dp_advance()] consumes it to produce
#' the next [dp_game].
#'
#' \describe{
#'   \item{`orders`}{The effective orders as a [dp_orders] tibble, with a
#'     `success` flag and a `note` per order.}
#'   \item{`units`}{Unit positions after the phase.}
#'   \item{`dislodged`}{Units dislodged by the phase, with the province the
#'     attack came from.}
#'   \item{`contested`}{Provinces where a standoff occurred.}
#'   \item{`disbanded`}{Units removed from the board.}
#'   \item{`built`}{Units added to the board.}
#'   \item{`season`, `year`, `phase`}{The turn that was resolved.}
#' }
#'
#' @name dp_result
#' @family engine
#' @seealso [dp_adjudicate()], [dp_advance()], [is_dp_result()]
#' @examples
#' res <- dp_adjudicate(dp_new_game(), dp_example_orders())
#' res$contested
NULL

#' A game record
#'
#' A `dp_history` is the turn-by-turn record of a game: for each turn, the state
#' before it, the orders submitted and the [dp_result] they produced. [dp_play()]
#' returns one, and [as_tibble()] flattens it to one row per power per turn.
#'
#' @name dp_history-class
#' @family analysis
#' @seealso [dp_history()], [dp_history_append()], [dp_plot_sc_history()]
#' @examples
#' h <- dp_play(bots = "hold", max_years = 2)
#' length(h)
NULL

#' A batch of simulated games
#'
#' A `dp_sim` collects the outcomes of many games played by bots. [dp_simulate()]
#' returns one; [dp_stats()] and the `dp_plot_*` functions summarise it.
#'
#' \describe{
#'   \item{`games`}{One row per game: `game`, `outcome`, `winner`, `years`,
#'     `turns`.}
#'   \item{`centres`}{Final supply-centre and unit counts, one row per game and
#'     power.}
#'   \item{`contests`}{How often a standoff occurred in each province.}
#'   \item{`settings`}{The arguments the simulation was run with.}
#' }
#'
#' @name dp_sim
#' @family simulation
#' @seealso [dp_simulate()], [dp_stats()], [is_dp_sim()]
#' @examples
#' sim <- dp_simulate(n = 1, bots = "hold", max_years = 2, verbose = FALSE)
#' sim$games
NULL
