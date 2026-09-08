# Append a turn to a game history

Append a turn to a game history

## Usage

``` r
dp_history_append(history, game, orders, result)
```

## Arguments

- history:

  A
  [dp_history](https://r-heller.github.io/diplomacyR/reference/dp_history.md)
  object.

- game:

  The game state before the turn.

- orders:

  The orders submitted for the turn.

- result:

  The
  [dp_result](https://r-heller.github.io/diplomacyR/reference/dp_result.md)
  the turn produced.

## Value

The history with one more turn.

## See also

Other analysis:
[`as_tibble.dp_history()`](https://r-heller.github.io/diplomacyR/reference/as_tibble.dp_history.md),
[`dp_history()`](https://r-heller.github.io/diplomacyR/reference/dp_history.md),
[`dp_history-class`](https://r-heller.github.io/diplomacyR/reference/dp_history-class.md),
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
dp_history_append(dp_history(), g, dp_example_orders(), res)
#> <dp_history> (1 turn)
#> • From Spring 1901 to Spring 1901
#> • Outcome: NA
```
