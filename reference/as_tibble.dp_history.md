# Coerce a game history to a tibble

Coerce a game history to a tibble

## Usage

``` r
# S3 method for class 'dp_history'
as_tibble(x, ...)
```

## Arguments

- x:

  A
  [dp_history](https://r-heller.github.io/diplomacyR/reference/dp_history.md)
  object.

- ...:

  Ignored.

## Value

A tibble with one row per power per turn and columns `turn`, `season`,
`year`, `phase`, `power`, `centres` and `units`.

## See also

Other analysis:
[`dp_history()`](https://r-heller.github.io/diplomacyR/reference/dp_history.md),
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
g <- dp_new_game()
res <- dp_adjudicate(g, dp_example_orders())
h <- dp_history_append(dp_history(), g, dp_example_orders(), res)
as_tibble(h)
#> # A tibble: 7 × 7
#>    turn season  year phase    power   centres units
#>   <int> <chr>  <int> <chr>    <chr>     <int> <int>
#> 1     1 Spring  1901 movement Russia        4     4
#> 2     1 Spring  1901 movement Austria       3     3
#> 3     1 Spring  1901 movement England       3     3
#> 4     1 Spring  1901 movement France        3     3
#> 5     1 Spring  1901 movement Germany       3     3
#> 6     1 Spring  1901 movement Italy         3     3
#> 7     1 Spring  1901 movement Turkey        3     3
```
