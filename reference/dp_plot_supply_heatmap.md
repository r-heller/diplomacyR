# Map how often each province was contested

Draws the board with each province shaded by the number of times a
standoff occurred there across the simulated games.

## Usage

``` r
dp_plot_supply_heatmap(sim, map = dp_map(), labels = TRUE)
```

## Arguments

- sim:

  A [dp_sim](https://r-heller.github.io/diplomacyR/reference/dp_sim.md)
  object.

- map:

  A [dp_map](https://r-heller.github.io/diplomacyR/reference/dp_map.md)
  object supplying the board coordinates.

- labels:

  Draw the three-letter province codes. Default `TRUE`.

## Value

A ggplot2 object.

## See also

Other plot:
[`autoplot.dp_game()`](https://r-heller.github.io/diplomacyR/reference/autoplot.dp_game.md),
[`dp_palette()`](https://r-heller.github.io/diplomacyR/reference/dp_palette.md),
[`dp_plot_centres()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_centres.md),
[`dp_plot_map()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_map.md),
[`dp_plot_sc_history()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_sc_history.md),
[`dp_plot_winrates()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_winrates.md)

## Examples

``` r
sim <- dp_simulate(n = 2, bots = "random", max_years = 2, verbose = FALSE)
dp_plot_supply_heatmap(sim)
```
