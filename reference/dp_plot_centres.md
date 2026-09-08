# Chart final supply centres by power

A box for the distribution with the individual games drawn over it, so
that a simulation of deterministic bots – where every game ends
identically – reads as a single point rather than a flat line of unclear
meaning.

## Usage

``` r
dp_plot_centres(sim)
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
[`dp_plot_map()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_map.md),
[`dp_plot_sc_history()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_sc_history.md),
[`dp_plot_supply_heatmap()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_supply_heatmap.md),
[`dp_plot_winrates()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_winrates.md)

## Examples

``` r
sim <- dp_simulate(n = 2, bots = "hold", max_years = 2, verbose = FALSE)
dp_plot_centres(sim)
```
