# Supply-centre trajectories from a game history

Supply-centre trajectories from a game history

## Usage

``` r
dp_sc_trajectory(history, wide = FALSE, powers = .dp_powers())
```

## Arguments

- history:

  A
  [dp_history](https://r-heller.github.io/diplomacyR/reference/dp_history.md)
  object.

- wide:

  Return one column per power instead of one row per power. Default
  `FALSE`.

- powers:

  Powers to include as columns when `wide = TRUE`. Defaults to the seven
  Great Powers, so the shape of the result does not depend on who
  happens to have survived.

## Value

A tibble taken at the movement phases only. In long form the columns are
`turn`, `season`, `year`, `power` and `centres`; in wide form they are
`turn`, `season`, `year` and one integer column per power.

## See also

Other analysis:
[`as_tibble.dp_history()`](https://r-heller.github.io/diplomacyR/reference/as_tibble.dp_history.md),
[`dp_history()`](https://r-heller.github.io/diplomacyR/reference/dp_history.md),
[`dp_history-class`](https://r-heller.github.io/diplomacyR/reference/dp_history-class.md),
[`dp_history_append()`](https://r-heller.github.io/diplomacyR/reference/dp_history_append.md),
[`dp_power_counts()`](https://r-heller.github.io/diplomacyR/reference/dp_power_counts.md),
[`dp_power_summary()`](https://r-heller.github.io/diplomacyR/reference/dp_power_summary.md),
[`dp_supply_centres()`](https://r-heller.github.io/diplomacyR/reference/dp_supply_centres.md),
[`dp_victory_check()`](https://r-heller.github.io/diplomacyR/reference/dp_victory_check.md),
[`is_dp_history()`](https://r-heller.github.io/diplomacyR/reference/is_dp_history.md)

## Examples

``` r
h <- dp_play(bots = "hold", max_years = 2)
dp_sc_trajectory(h)
#> # A tibble: 28 × 5
#>     turn season  year power   centres
#>    <int> <chr>  <int> <chr>     <int>
#>  1     1 Spring  1901 Russia        4
#>  2     1 Spring  1901 Austria       3
#>  3     1 Spring  1901 England       3
#>  4     1 Spring  1901 France        3
#>  5     1 Spring  1901 Germany       3
#>  6     1 Spring  1901 Italy         3
#>  7     1 Spring  1901 Turkey        3
#>  8     2 Fall    1901 Russia        4
#>  9     2 Fall    1901 Austria       3
#> 10     2 Fall    1901 England       3
#> # ℹ 18 more rows
dp_sc_trajectory(h, wide = TRUE)
#> # A tibble: 4 × 10
#>    turn season  year Austria England France Germany Italy Russia Turkey
#>   <int> <chr>  <int>   <int>   <int>  <int>   <int> <int>  <int>  <int>
#> 1     1 Spring  1901       3       3      3       3     3      4      3
#> 2     2 Fall    1901       3       3      3       3     3      4      3
#> 3     4 Spring  1902       3       3      3       3     3      4      3
#> 4     5 Fall    1902       3       3      3       3     3      4      3
```
