# Enumerate the legal orders available to a power

Lists every order a power may legally issue in the current phase: holds,
moves (including convoyed moves), supports and convoys during movement;
retreats and disbands during a retreat phase; builds and disbands during
an adjustment phase. Bots and the Shiny order editor both use this to
stay inside the rules.

## Usage

``` r
dp_legal_orders(game, power = NULL, unit = NULL, call = rlang::caller_env())
```

## Arguments

- game:

  A
  [dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
  object.

- power:

  The power to enumerate orders for. `NULL` enumerates every power.

- unit:

  Optional location; restricts the result to that unit.

- call:

  Caller environment, for error reporting. Experts only.

## Value

A `dp_orders` tibble, possibly with zero rows.

## See also

Other orders:
[`as_tibble.dp_orders()`](https://r-heller.github.io/diplomacyR/reference/as_tibble.dp_orders.md),
[`dp_bind_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_bind_orders.md),
[`dp_example_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_example_orders.md),
[`dp_order()`](https://r-heller.github.io/diplomacyR/reference/dp_order.md),
[`dp_orders`](https://r-heller.github.io/diplomacyR/reference/dp_orders.md),
[`dp_parse_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_parse_orders.md),
[`format.dp_orders()`](https://r-heller.github.io/diplomacyR/reference/format.dp_orders.md),
[`is_dp_orders()`](https://r-heller.github.io/diplomacyR/reference/is_dp_orders.md)

## Examples

``` r
g <- dp_new_game()
head(dp_legal_orders(g, "France"))
#> <dp_orders> (6 orders)
#> France: F Bre H
#> France: F Bre - Eng
#> France: F Bre - Gas
#> France: F Bre - Mao
#> France: F Bre - Pic
#> France: F Bre S F Lon - Eng
```
