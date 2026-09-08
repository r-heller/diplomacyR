# Start an empty game history

A `dp_history` records the state, the orders and the outcome of every
turn of a game, so that a game can be replayed, charted or analysed
after the fact.

## Usage

``` r
dp_history()
```

## Value

An empty dp_history object.

## See also

Other analysis:
[`as_tibble.dp_history()`](https://r-heller.github.io/diplomacyR/reference/as_tibble.dp_history.md),
[`dp_history-class`](https://r-heller.github.io/diplomacyR/reference/dp_history-class.md),
[`dp_history_append()`](https://r-heller.github.io/diplomacyR/reference/dp_history_append.md),
[`dp_power_counts()`](https://r-heller.github.io/diplomacyR/reference/dp_power_counts.md),
[`dp_power_summary()`](https://r-heller.github.io/diplomacyR/reference/dp_power_summary.md),
[`dp_sc_trajectory()`](https://r-heller.github.io/diplomacyR/reference/dp_sc_trajectory.md),
[`dp_supply_centres()`](https://r-heller.github.io/diplomacyR/reference/dp_supply_centres.md),
[`dp_victory_check()`](https://r-heller.github.io/diplomacyR/reference/dp_victory_check.md),
[`is_dp_history()`](https://r-heller.github.io/diplomacyR/reference/is_dp_history.md)

## Examples

``` r
dp_history()
#> <dp_history> (0 turns)
```
