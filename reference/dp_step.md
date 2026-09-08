# Resolve one phase and advance the game

Adjudicates the current phase – movement, retreat or adjustment – and
returns the next game state. Any power without orders is played by
`bots`.

## Usage

``` r
dp_step(game, orders = NULL, bots = "greedy", call = rlang::caller_env())
```

## Arguments

- game:

  A
  [dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
  object.

- orders:

  Orders for this phase, as a `dp_orders` tibble or a character vector.
  `NULL` lets the bots order every power.

- bots:

  Bot assignment for powers with no orders: a single bot name or a named
  character vector. See
  [`dp_ai_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_ai_orders.md).

- call:

  Caller environment, for error reporting. Experts only.

## Value

The next
[dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
state. The result that produced it is stored in the `last_result`
element.

## See also

Other engine:
[`dp_adjudicate()`](https://r-heller.github.io/diplomacyR/reference/dp_adjudicate.md),
[`dp_advance()`](https://r-heller.github.io/diplomacyR/reference/dp_advance.md),
[`dp_build()`](https://r-heller.github.io/diplomacyR/reference/dp_build.md),
[`dp_play()`](https://r-heller.github.io/diplomacyR/reference/dp_play.md),
[`dp_result`](https://r-heller.github.io/diplomacyR/reference/dp_result.md),
[`dp_retreat()`](https://r-heller.github.io/diplomacyR/reference/dp_retreat.md),
[`is_dp_result()`](https://r-heller.github.io/diplomacyR/reference/is_dp_result.md)

## Examples

``` r
g <- dp_new_game()
g2 <- dp_step(g, bots = "hold")
g2$season
#> [1] "Fall"
```
