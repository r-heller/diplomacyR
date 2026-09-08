# Summarise the powers of a game, a history or a simulation

Summarise the powers of a game, a history or a simulation

## Usage

``` r
dp_power_summary(x, ...)

# S3 method for class 'dp_game'
dp_power_summary(x, ...)

# S3 method for class 'dp_history'
dp_power_summary(x, ...)

# S3 method for class 'dp_sim'
dp_power_summary(x, ...)
```

## Arguments

- x:

  A
  [dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md),
  [dp_history](https://r-heller.github.io/diplomacyR/reference/dp_history.md)
  or [dp_sim](https://r-heller.github.io/diplomacyR/reference/dp_sim.md)
  object.

- ...:

  Passed to methods.

## Value

A tibble with one row per power.

## See also

Other analysis:
[`as_tibble.dp_history()`](https://r-heller.github.io/diplomacyR/reference/as_tibble.dp_history.md),
[`dp_history()`](https://r-heller.github.io/diplomacyR/reference/dp_history.md),
[`dp_history-class`](https://r-heller.github.io/diplomacyR/reference/dp_history-class.md),
[`dp_history_append()`](https://r-heller.github.io/diplomacyR/reference/dp_history_append.md),
[`dp_power_counts()`](https://r-heller.github.io/diplomacyR/reference/dp_power_counts.md),
[`dp_sc_trajectory()`](https://r-heller.github.io/diplomacyR/reference/dp_sc_trajectory.md),
[`dp_supply_centres()`](https://r-heller.github.io/diplomacyR/reference/dp_supply_centres.md),
[`dp_victory_check()`](https://r-heller.github.io/diplomacyR/reference/dp_victory_check.md),
[`is_dp_history()`](https://r-heller.github.io/diplomacyR/reference/is_dp_history.md)

## Examples

``` r
dp_power_summary(dp_new_game())
#> # A tibble: 7 × 6
#>   power   centres units delta home_centres status 
#>   <chr>     <int> <int> <int>        <int> <chr>  
#> 1 Russia        4     4     0            4 playing
#> 2 Austria       3     3     0            3 playing
#> 3 England       3     3     0            3 playing
#> 4 France        3     3     0            3 playing
#> 5 Germany       3     3     0            3 playing
#> 6 Italy         3     3     0            3 playing
#> 7 Turkey        3     3     0            3 playing
```
