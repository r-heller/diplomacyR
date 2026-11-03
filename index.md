# diplomacyR

diplomacyR is a complete engine for the board game Diplomacy on the
standard seven-power pre-1914 map. It gives you a rules-accurate
adjudicator for simultaneous movement, the full phase machine from
Spring 1901 to a solo victory, scriptable bots, batch simulation with
outcome analysis, and a **shiny** application for interactive play.

Diplomacy has no dice. Every player writes orders for every unit in
secret, all the orders are revealed at once, and one set of rules
decides what actually happened — including the cases where the outcome
of one order depends on the outcome of another that depends back on the
first. Getting that right is what most of this package is.

## Installation

``` r

# install.packages("pak")
pak::pak("r-heller/diplomacyR")
```

For a local checkout, use R 4.1 or later and run:

``` r

install.packages("remotes")
remotes::install_deps(dependencies = TRUE)
remotes::install_local(".", dependencies = FALSE)
```

Seeded games and simulations restore the caller’s random state,
including when a run fails. Counts and seeds must be finite integers
within R’s integer range.

## A first turn

``` r

library(diplomacyR)

game <- dp_new_game()
game
#> <dp_game> Spring 1901 (movement phase)
#> Russia    4 centres   4 units
#> Austria   3 centres   3 units
#> England   3 centres   3 units
#> France    3 centres   3 units
#> Germany   3 centres   3 units
#> Italy     3 centres   3 units
#> Turkey    3 centres   3 units
```

Orders are written the way players write them, and resolved with
[`dp_adjudicate()`](https://r-heller.github.io/diplomacyR/reference/dp_adjudicate.md).
Here France attacks Burgundy with support while Germany attacks it
alone: two against one.

``` r

result <- dp_adjudicate(game, dp_parse_orders(c(
  "France: A Par - Bur",
  "France: A Mar S A Par - Bur",
  "Germany: A Mun - Bur"
)))

result$orders[result$orders$loc %in% c("par", "mar", "mun"), ]
#> <dp_orders> (3 orders)
#> ✓ France: A Mar S A Par - Bur
#> ✓ France: A Par - Bur
#> ✗ Germany: A Mun - Bur
```

Every power that was not ordered simply held, which is what the rules
say happens to a unit with no orders.
[`dp_advance()`](https://r-heller.github.io/diplomacyR/reference/dp_advance.md)
applies the result and steps the season, phase and year.

``` r

game <- dp_advance(game, result)
game
#> <dp_game> Fall 1901 (movement phase)
#> Russia    4 centres   4 units
#> Austria   3 centres   3 units
#> England   3 centres   3 units
#> France    3 centres   3 units
#> Germany   3 centres   3 units
#> Italy     3 centres   3 units
#> Turkey    3 centres   3 units
```

To watch a whole game instead, hand it to the bots:

``` r

history <- dp_play(bots = "greedy", max_years = 3, seed = 1)
dp_power_summary(history)
#> # A tibble: 7 × 6
#>   power   turns start_centres final_centres peak_centres mean_centres
#>   <chr>   <int>         <int>         <int>        <int>        <dbl>
#> 1 Germany    11             3             8            8         5.27
#> 2 Turkey     11             3             7            7         5.18
#> 3 France     11             3             4            4         3.82
#> 4 Italy      11             3             4            4         3.09
#> 5 Austria    11             3             3            3         3   
#> 6 England    11             3             3            3         3   
#> 7 Russia     11             4             2            4         3.09
```

## What is in the box

- **The board.**
  [`dp_map()`](https://r-heller.github.io/diplomacyR/reference/dp_map.md)
  loads the standard 75-province, 34-centre map with separate army and
  fleet adjacency graphs and per-coast fleet locations.
- **The adjudicator.**
  [`dp_adjudicate()`](https://r-heller.github.io/diplomacyR/reference/dp_adjudicate.md)
  resolves movement phases — supports, support cutting, standoffs,
  dislodgement, head-to-head battles, convoys and convoy paradoxes.
  [`dp_retreat()`](https://r-heller.github.io/diplomacyR/reference/dp_retreat.md)
  and
  [`dp_build()`](https://r-heller.github.io/diplomacyR/reference/dp_build.md)
  handle the other two phase types, and
  [`dp_advance()`](https://r-heller.github.io/diplomacyR/reference/dp_advance.md)
  drives the season machine.
- **Orders.**
  [`dp_parse_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_parse_orders.md)
  reads standard notation in all its usual spellings;
  [`format()`](https://rdrr.io/r/base/format.html) renders any order set
  back to canonical text;
  [`dp_legal_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_legal_orders.md)
  enumerates everything the rules currently permit.
- **Bots.** Four of them — `"random"`, `"hold"`, `"greedy"` and the
  experimental `"negotiator"` — through
  [`dp_ai_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_ai_orders.md),
  plus
  [`dp_step()`](https://r-heller.github.io/diplomacyR/reference/dp_step.md)
  and
  [`dp_play()`](https://r-heller.github.io/diplomacyR/reference/dp_play.md)
  to drive whole games.
- **Simulation and analysis.**
  [`dp_simulate()`](https://r-heller.github.io/diplomacyR/reference/dp_simulate.md)
  runs batches,
  [`dp_stats()`](https://r-heller.github.io/diplomacyR/reference/dp_stats.md)
  and
  [`dp_power_summary()`](https://r-heller.github.io/diplomacyR/reference/dp_power_summary.md)
  summarise them, and the `dp_plot_*()` functions return **ggplot2**
  objects for the board, supply-centre trajectories, win rates and where
  the fighting happens.

## Rules conformance

The adjudicator is validated against the Diplomacy Adjudicator Test
Cases, the reference suite assembled by Lucas B. Kruijswijk. It passes
all 130 movement-phase cases, sections 6.A to 6.G: legality and coasts,
circular movement, supports and dislodges, head-to-head battles,
convoys, convoy paradoxes and convoying to one’s own area. Where the
suite allows more than one defensible answer, the engine implements the
option it marks as preferred. The encoded cases ship with the package
under `extdata/datc`.

## The application

``` r

dp_run_app()
```

A **shiny** interface with an interactive board, an order editor that
checks legality as you type, a turn adjudicator, a replayable history,
analysis charts and a batch-simulation runner. It needs **shiny**,
**bslib** and **DT**, which are suggested rather than required.

## Learning more

- [`vignette("diplomacyR")`](https://r-heller.github.io/diplomacyR/articles/diplomacyR.md)
  — getting started.
- [`vignette("notation")`](https://r-heller.github.io/diplomacyR/articles/notation.md)
  — the order-notation reference.
- [`vignette("adjudication")`](https://r-heller.github.io/diplomacyR/articles/adjudication.md)
  — how a turn is resolved, worked position by worked position.
- [`vignette("ai-and-simulation")`](https://r-heller.github.io/diplomacyR/articles/ai-and-simulation.md)
  — bots, batch simulation and the analysis plots.
- [`vignette("design")`](https://r-heller.github.io/diplomacyR/articles/design.md)
  — the S3 architecture, the resolver, and how coasts are modelled.

## Licence

MIT. Diplomacy is a trademark of its respective owners; this package is
an independent implementation of the published rules and is not
affiliated with or endorsed by them.
