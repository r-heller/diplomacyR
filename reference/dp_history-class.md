# A game record

A `dp_history` is the turn-by-turn record of a game: for each turn, the
state before it, the orders submitted and the
[dp_result](https://r-heller.github.io/diplomacyR/reference/dp_result.md)
they produced.
[`dp_play()`](https://r-heller.github.io/diplomacyR/reference/dp_play.md)
returns one, and
[`as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
flattens it to one row per power per turn.

## See also

[`dp_history()`](https://r-heller.github.io/diplomacyR/reference/dp_history.md),
[`dp_history_append()`](https://r-heller.github.io/diplomacyR/reference/dp_history_append.md),
[`dp_plot_sc_history()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_sc_history.md)

Other analysis:
[`as_tibble.dp_history()`](https://r-heller.github.io/diplomacyR/reference/as_tibble.dp_history.md),
[`dp_history()`](https://r-heller.github.io/diplomacyR/reference/dp_history.md),
[`dp_history_append()`](https://r-heller.github.io/diplomacyR/reference/dp_history_append.md),
[`dp_power_counts()`](https://r-heller.github.io/diplomacyR/reference/dp_power_counts.md),
[`dp_power_summary()`](https://r-heller.github.io/diplomacyR/reference/dp_power_summary.md),
[`dp_sc_trajectory()`](https://r-heller.github.io/diplomacyR/reference/dp_sc_trajectory.md),
[`dp_supply_centres()`](https://r-heller.github.io/diplomacyR/reference/dp_supply_centres.md),
[`dp_victory_check()`](https://r-heller.github.io/diplomacyR/reference/dp_victory_check.md),
[`is_dp_history()`](https://r-heller.github.io/diplomacyR/reference/is_dp_history.md)

## Examples

``` r
h <- dp_play(bots = "hold", max_years = 2)
length(h)
#> [1] 6
```
