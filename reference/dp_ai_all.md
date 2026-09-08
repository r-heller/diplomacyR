# Orders for every power in a game

Orders for every power in a game

## Usage

``` r
dp_ai_all(game, bots = "greedy", call = rlang::caller_env())
```

## Arguments

- game:

  A
  [dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
  object.

- bots:

  Either one bot name for all powers, or a named character vector
  mapping power to bot.

- call:

  Caller environment, for error reporting. Experts only.

## Value

A `dp_orders` tibble covering every power.

## See also

Other ai:
[`dp_ai_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_ai_orders.md)

## Examples

``` r
g <- dp_new_game()
nrow(dp_ai_all(g, bots = "hold"))
#> [1] 22
```
