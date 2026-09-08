# Generate orders for a power using a bot

Produces a complete, legal order set for one power in the game's current
phase.

## Usage

``` r
dp_ai_orders(game, power, bot = "greedy", ...)
```

## Arguments

- game:

  A
  [dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
  object.

- power:

  The power to generate orders for.

- bot:

  Bot strategy:

  - `"random"` – picks uniformly among that unit's legal orders.

  - `"hold"` – holds everything, disbands when forced to choose.

  - `"greedy"` – walks each unit towards the nearest supply centre it
    does not own and supports its own attacks.

  - `"negotiator"` – greedy, plus a crude model of who the threat is.
    Experimental.

- ...:

  Passed to the individual bot.

## Value

A `dp_orders` tibble of legal orders for `power`.

## See also

Other ai:
[`dp_ai_all()`](https://r-heller.github.io/diplomacyR/reference/dp_ai_all.md)

## Examples

``` r
g <- dp_new_game()
dp_ai_orders(g, "France", bot = "greedy")
#> <dp_orders> (3 orders)
#> France: F Bre - Eng
#> France: A Mar - Spa
#> France: A Par - Bur
```
