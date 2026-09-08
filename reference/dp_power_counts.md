# Count supply centres and units per power

Count supply centres and units per power

## Usage

``` r
dp_power_counts(game)
```

## Arguments

- game:

  A
  [dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
  object.

## Value

A tibble with columns `power`, `centres`, `units` and `delta`, one row
per power, ordered by centres.

## See also

Other analysis:
[`as_tibble.dp_history()`](https://r-heller.github.io/diplomacyR/reference/as_tibble.dp_history.md),
[`dp_history()`](https://r-heller.github.io/diplomacyR/reference/dp_history.md),
[`dp_history-class`](https://r-heller.github.io/diplomacyR/reference/dp_history-class.md),
[`dp_history_append()`](https://r-heller.github.io/diplomacyR/reference/dp_history_append.md),
[`dp_power_summary()`](https://r-heller.github.io/diplomacyR/reference/dp_power_summary.md),
[`dp_sc_trajectory()`](https://r-heller.github.io/diplomacyR/reference/dp_sc_trajectory.md),
[`dp_supply_centres()`](https://r-heller.github.io/diplomacyR/reference/dp_supply_centres.md),
[`dp_victory_check()`](https://r-heller.github.io/diplomacyR/reference/dp_victory_check.md),
[`is_dp_history()`](https://r-heller.github.io/diplomacyR/reference/is_dp_history.md)

## Examples

``` r
dp_power_counts(dp_new_game())
#> # A tibble: 7 × 4
#>   power   centres units delta
#>   <chr>     <int> <int> <int>
#> 1 Russia        4     4     0
#> 2 Austria       3     3     0
#> 3 England       3     3     0
#> 4 France        3     3     0
#> 5 Germany       3     3     0
#> 6 Italy         3     3     0
#> 7 Turkey        3     3     0
```
