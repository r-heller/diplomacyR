# Package index

## Classes

The six S3 objects the package is built from.

- [`dp_game`](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
  : The game state
- [`dp_map-class`](https://r-heller.github.io/diplomacyR/reference/dp_map-class.md)
  : The board
- [`dp_orders`](https://r-heller.github.io/diplomacyR/reference/dp_orders.md)
  : A set of orders
- [`dp_result`](https://r-heller.github.io/diplomacyR/reference/dp_result.md)
  : The outcome of a phase
- [`dp_history-class`](https://r-heller.github.io/diplomacyR/reference/dp_history-class.md)
  : A game record
- [`dp_sim`](https://r-heller.github.io/diplomacyR/reference/dp_sim.md)
  : A batch of simulated games

## Setup

The board, the units and a game to play on it.

- [`dp_map()`](https://r-heller.github.io/diplomacyR/reference/dp_map.md)
  : Load a Diplomacy board
- [`dp_provinces()`](https://r-heller.github.io/diplomacyR/reference/dp_provinces.md)
  : List the provinces of a board
- [`dp_adjacent()`](https://r-heller.github.io/diplomacyR/reference/dp_adjacent.md)
  : Neighbours of a location
- [`dp_home_centres()`](https://r-heller.github.io/diplomacyR/reference/dp_home_centres.md)
  : Home supply centres
- [`dp_new_game()`](https://r-heller.github.io/diplomacyR/reference/dp_new_game.md)
  : Start a new standard Diplomacy game
- [`dp_game_from_units()`](https://r-heller.github.io/diplomacyR/reference/dp_game_from_units.md)
  : Build a game state from an explicit position
- [`dp_units()`](https://r-heller.github.io/diplomacyR/reference/dp_units.md)
  : Units currently on the board
- [`dp_unit()`](https://r-heller.github.io/diplomacyR/reference/dp_unit.md)
  : Describe a unit
- [`dp_example_game()`](https://r-heller.github.io/diplomacyR/reference/dp_example_game.md)
  : Example game positions

## Orders

Writing, parsing and enumerating orders.

- [`dp_order()`](https://r-heller.github.io/diplomacyR/reference/dp_order.md)
  : Construct a Diplomacy order
- [`dp_parse_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_parse_orders.md)
  : Parse Diplomacy order notation
- [`dp_bind_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_bind_orders.md)
  : Combine orders
- [`dp_legal_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_legal_orders.md)
  : Enumerate the legal orders available to a power
- [`dp_example_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_example_orders.md)
  : Example order sets
- [`format(`*`<dp_orders>`*`)`](https://r-heller.github.io/diplomacyR/reference/format.dp_orders.md)
  : Render orders as standard notation

## Engine

Adjudicating a phase and stepping the game forward.

- [`dp_adjudicate()`](https://r-heller.github.io/diplomacyR/reference/dp_adjudicate.md)
  : Adjudicate a movement phase
- [`dp_retreat()`](https://r-heller.github.io/diplomacyR/reference/dp_retreat.md)
  : Adjudicate a retreat phase
- [`dp_build()`](https://r-heller.github.io/diplomacyR/reference/dp_build.md)
  : Adjudicate a build phase
- [`dp_advance()`](https://r-heller.github.io/diplomacyR/reference/dp_advance.md)
  : Advance a game by applying an adjudication result
- [`dp_step()`](https://r-heller.github.io/diplomacyR/reference/dp_step.md)
  : Resolve one phase and advance the game
- [`dp_play()`](https://r-heller.github.io/diplomacyR/reference/dp_play.md)
  : Play a game to completion

## AI

Scriptable bots.

- [`dp_ai_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_ai_orders.md)
  : Generate orders for a power using a bot
- [`dp_ai_all()`](https://r-heller.github.io/diplomacyR/reference/dp_ai_all.md)
  : Orders for every power in a game

## Simulation

Playing many games and summarising them.

- [`dp_simulate()`](https://r-heller.github.io/diplomacyR/reference/dp_simulate.md)
  : Simulate many Diplomacy games
- [`dp_stats()`](https://r-heller.github.io/diplomacyR/reference/dp_stats.md)
  : Summarise a batch of simulated games

## Analysis

Supply centres, victory conditions and per-power summaries.

- [`dp_supply_centres()`](https://r-heller.github.io/diplomacyR/reference/dp_supply_centres.md)
  : Supply centres of a board or a game
- [`dp_power_counts()`](https://r-heller.github.io/diplomacyR/reference/dp_power_counts.md)
  : Count supply centres and units per power
- [`dp_power_summary()`](https://r-heller.github.io/diplomacyR/reference/dp_power_summary.md)
  : Summarise the powers of a game, a history or a simulation
- [`dp_victory_check()`](https://r-heller.github.io/diplomacyR/reference/dp_victory_check.md)
  : Check for a solo victory or a draw
- [`dp_sc_trajectory()`](https://r-heller.github.io/diplomacyR/reference/dp_sc_trajectory.md)
  : Supply-centre trajectories from a game history
- [`dp_history()`](https://r-heller.github.io/diplomacyR/reference/dp_history.md)
  : Start an empty game history
- [`dp_history_append()`](https://r-heller.github.io/diplomacyR/reference/dp_history_append.md)
  : Append a turn to a game history

## Plot

Every renderer returns a ggplot2 object.

- [`dp_plot_map()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_map.md)
  : Draw the board
- [`dp_plot_sc_history()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_sc_history.md)
  : Chart supply-centre counts over a game
- [`dp_plot_winrates()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_winrates.md)
  : Chart win rates by power
- [`dp_plot_centres()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_centres.md)
  : Chart final supply centres by power
- [`dp_plot_supply_heatmap()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_supply_heatmap.md)
  : Map how often each province was contested
- [`dp_palette()`](https://r-heller.github.io/diplomacyR/reference/dp_palette.md)
  : Colours for the seven Great Powers
- [`autoplot(`*`<dp_game>`*`)`](https://r-heller.github.io/diplomacyR/reference/autoplot.dp_game.md)
  : Plot a game state

## App

- [`dp_run_app()`](https://r-heller.github.io/diplomacyR/reference/dp_run_app.md)
  : Launch the diplomacyR application

## Class predicates and coercion

- [`is_dp_map()`](https://r-heller.github.io/diplomacyR/reference/is_dp_map.md)
  : Test whether an object is a board
- [`is_dp_game()`](https://r-heller.github.io/diplomacyR/reference/is_dp_game.md)
  : Test whether an object is a game
- [`is_dp_orders()`](https://r-heller.github.io/diplomacyR/reference/is_dp_orders.md)
  : Test whether an object is an orders tibble
- [`is_dp_result()`](https://r-heller.github.io/diplomacyR/reference/is_dp_result.md)
  : Test whether an object is an adjudication result
- [`is_dp_history()`](https://r-heller.github.io/diplomacyR/reference/is_dp_history.md)
  : Test whether an object is a game history
- [`is_dp_sim()`](https://r-heller.github.io/diplomacyR/reference/is_dp_sim.md)
  : Test whether an object is a simulation result
- [`as_tibble(`*`<dp_history>`*`)`](https://r-heller.github.io/diplomacyR/reference/as_tibble.dp_history.md)
  : Coerce a game history to a tibble
- [`as_tibble(`*`<dp_orders>`*`)`](https://r-heller.github.io/diplomacyR/reference/as_tibble.dp_orders.md)
  : Coerce orders to a tibble
- [`length(`*`<dp_history>`*`)`](https://r-heller.github.io/diplomacyR/reference/length.dp_history.md)
  : Number of turns recorded
- [`reexports`](https://r-heller.github.io/diplomacyR/reference/reexports.md)
  [`as_tibble`](https://r-heller.github.io/diplomacyR/reference/reexports.md)
  [`autoplot`](https://r-heller.github.io/diplomacyR/reference/reexports.md)
  [`%||%`](https://r-heller.github.io/diplomacyR/reference/reexports.md)
  : Objects exported from other packages
