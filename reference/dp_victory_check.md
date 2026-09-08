# Check for a solo victory or a draw

A power wins outright by controlling `threshold` supply centres, 18 of
the 34 on the standard board. A game that reaches its turn cap without a
solo ends in a draw between the surviving powers.

## Usage

``` r
dp_victory_check(game, threshold = 18L)
```

## Arguments

- game:

  A
  [dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
  object.

- threshold:

  Centres needed for a solo victory. Default `18`.

## Value

A list with `winner` (a power or `NA`), `over` (logical), `outcome`
(`"solo"`, `"draw"` or `NA`), `survivors` and the per-power `counts`
tibble.

## See also

Other analysis:
[`as_tibble.dp_history()`](https://r-heller.github.io/diplomacyR/reference/as_tibble.dp_history.md),
[`dp_history()`](https://r-heller.github.io/diplomacyR/reference/dp_history.md),
[`dp_history-class`](https://r-heller.github.io/diplomacyR/reference/dp_history-class.md),
[`dp_history_append()`](https://r-heller.github.io/diplomacyR/reference/dp_history_append.md),
[`dp_power_counts()`](https://r-heller.github.io/diplomacyR/reference/dp_power_counts.md),
[`dp_power_summary()`](https://r-heller.github.io/diplomacyR/reference/dp_power_summary.md),
[`dp_sc_trajectory()`](https://r-heller.github.io/diplomacyR/reference/dp_sc_trajectory.md),
[`dp_supply_centres()`](https://r-heller.github.io/diplomacyR/reference/dp_supply_centres.md),
[`is_dp_history()`](https://r-heller.github.io/diplomacyR/reference/is_dp_history.md)

## Examples

``` r
dp_victory_check(dp_new_game())
#> $winner
#> [1] NA
#> 
#> $over
#> [1] FALSE
#> 
#> $outcome
#> [1] NA
#> 
#> $survivors
#> [1] "Russia"  "Austria" "England" "France"  "Germany" "Italy"   "Turkey" 
#> 
#> $counts
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
#> 
```
