# Test whether an object is a game history

Test whether an object is a game history

## Usage

``` r
is_dp_history(x)
```

## Arguments

- x:

  An object to test.

## Value

A logical scalar.

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
[`dp_victory_check()`](https://r-heller.github.io/diplomacyR/reference/dp_victory_check.md)

## Examples

``` r
is_dp_history(dp_history())
#> [1] TRUE
```
