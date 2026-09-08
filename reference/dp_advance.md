# Advance a game by applying an adjudication result

Applies the outcome of a phase to the game state and steps the season,
phase and year machine. Supply-centre ownership is recalculated as the
game leaves the autumn, and a solo victory or elimination is recorded in
the game's status.

## Usage

``` r
dp_advance(game, result, call = rlang::caller_env())
```

## Arguments

- game:

  A
  [dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
  object.

- result:

  A
  [dp_result](https://r-heller.github.io/diplomacyR/reference/dp_result.md)
  from
  [`dp_adjudicate()`](https://r-heller.github.io/diplomacyR/reference/dp_adjudicate.md),
  [`dp_retreat()`](https://r-heller.github.io/diplomacyR/reference/dp_retreat.md)
  or
  [`dp_build()`](https://r-heller.github.io/diplomacyR/reference/dp_build.md).

- call:

  Caller environment, for error reporting. Experts only.

## Value

The next
[dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
state.

## See also

Other engine:
[`dp_adjudicate()`](https://r-heller.github.io/diplomacyR/reference/dp_adjudicate.md),
[`dp_build()`](https://r-heller.github.io/diplomacyR/reference/dp_build.md),
[`dp_play()`](https://r-heller.github.io/diplomacyR/reference/dp_play.md),
[`dp_result`](https://r-heller.github.io/diplomacyR/reference/dp_result.md),
[`dp_retreat()`](https://r-heller.github.io/diplomacyR/reference/dp_retreat.md),
[`dp_step()`](https://r-heller.github.io/diplomacyR/reference/dp_step.md),
[`is_dp_result()`](https://r-heller.github.io/diplomacyR/reference/is_dp_result.md)

## Examples

``` r
g <- dp_new_game()
res <- dp_adjudicate(g, dp_example_orders("spring_1901"))
dp_advance(g, res)
#> <dp_game> Fall 1901 (movement phase)
#> Russia    4 centres   4 units
#> Austria   3 centres   3 units
#> England   3 centres   3 units
#> France    3 centres   3 units
#> Germany   3 centres   3 units
#> Italy     3 centres   3 units
#> Turkey    3 centres   3 units
```
