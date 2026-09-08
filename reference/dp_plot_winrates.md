# Chart win rates by power

One bar per power against a light track running the full width, so that
a power with no solo victories is still visible and still labelled. Each
bar is annotated with the underlying count.

## Usage

``` r
dp_plot_winrates(sim)
```

## Arguments

- sim:

  A [dp_sim](https://r-heller.github.io/diplomacyR/reference/dp_sim.md)
  object.

## Value

A ggplot2 object.

## See also

Other plot:
[`autoplot.dp_game()`](https://r-heller.github.io/diplomacyR/reference/autoplot.dp_game.md),
[`dp_palette()`](https://r-heller.github.io/diplomacyR/reference/dp_palette.md),
[`dp_plot_centres()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_centres.md),
[`dp_plot_map()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_map.md),
[`dp_plot_sc_history()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_sc_history.md),
[`dp_plot_supply_heatmap()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_supply_heatmap.md)

## Examples

``` r
sim <- dp_simulate(n = 2, bots = "hold", max_years = 2, verbose = FALSE)
dp_plot_winrates(sim)
```
