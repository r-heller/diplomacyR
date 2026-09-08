# Adjudicate a build phase

Reconciles each power's unit count with its supply-centre count. A power
with centres to spare may build in its own home centres, provided it
still owns them and they are empty; fleets may only be built in coastal
home centres, naming a coast where the province has more than one. A
power with too many units must disband the difference, and any shortfall
in its orders is made up by the civil-disorder rule: the unit furthest
from home goes first, a fleet before an army at equal distance, ties
broken alphabetically.

## Usage

``` r
dp_build(game, orders = NULL, call = rlang::caller_env())
```

## Arguments

- game:

  A
  [dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
  object in a build phase.

- orders:

  A `dp_orders` tibble, or a character vector of orders such as
  `"Build A Par"` and `"Remove F Bre"`.

- call:

  Caller environment, for error reporting. Experts only.

## Value

A
[dp_result](https://r-heller.github.io/diplomacyR/reference/dp_result.md)
object with the new unit positions, the units built and the units
disbanded.

## See also

Other engine:
[`dp_adjudicate()`](https://r-heller.github.io/diplomacyR/reference/dp_adjudicate.md),
[`dp_advance()`](https://r-heller.github.io/diplomacyR/reference/dp_advance.md),
[`dp_play()`](https://r-heller.github.io/diplomacyR/reference/dp_play.md),
[`dp_result`](https://r-heller.github.io/diplomacyR/reference/dp_result.md),
[`dp_retreat()`](https://r-heller.github.io/diplomacyR/reference/dp_retreat.md),
[`dp_step()`](https://r-heller.github.io/diplomacyR/reference/dp_step.md),
[`is_dp_result()`](https://r-heller.github.io/diplomacyR/reference/is_dp_result.md)

## Examples

``` r
g <- dp_example_game("build")
dp_build(g, "Germany: Build A Ber")
#> <dp_result> Winter 1902 (build phase)
#> • 2 of 2 orders succeeded
#> • 0 units dislodged
#> • 0 provinces left contested
#> • 1 unit disbanded
#> • 1 unit built
```
