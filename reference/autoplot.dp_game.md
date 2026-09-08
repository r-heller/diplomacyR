# Plot a game state

Plot a game state

## Usage

``` r
# S3 method for class 'dp_game'
autoplot(object, ...)
```

## Arguments

- object:

  A
  [dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
  object.

- ...:

  Passed to
  [`dp_plot_map()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_map.md).

## Value

A ggplot2 object.

## See also

Other plot:
[`dp_palette()`](https://r-heller.github.io/diplomacyR/reference/dp_palette.md),
[`dp_plot_centres()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_centres.md),
[`dp_plot_map()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_map.md),
[`dp_plot_sc_history()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_sc_history.md),
[`dp_plot_supply_heatmap()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_supply_heatmap.md),
[`dp_plot_winrates()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_winrates.md)

## Examples

``` r
autoplot(dp_new_game())
```
