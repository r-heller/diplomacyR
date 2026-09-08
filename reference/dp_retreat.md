# Adjudicate a retreat phase

Each dislodged unit either retreats to a legal destination or is
disbanded. A unit with no order, with an order the rules forbid, or with
no legal destination at all, disbands. When two or more units retreat to
the same province they all disband.

## Usage

``` r
dp_retreat(game, orders = NULL, call = rlang::caller_env())
```

## Arguments

- game:

  A
  [dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
  object in a retreat phase.

- orders:

  A `dp_orders` tibble, or a character vector of orders. Retreats may be
  written `"A Tri R Alb"` or, in a retreat phase, simply
  `"A Tri - Alb"`.

- call:

  Caller environment, for error reporting. Experts only.

## Value

A
[dp_result](https://r-heller.github.io/diplomacyR/reference/dp_result.md)
object with the surviving unit positions and the units that disbanded.

## See also

Other engine:
[`dp_adjudicate()`](https://r-heller.github.io/diplomacyR/reference/dp_adjudicate.md),
[`dp_advance()`](https://r-heller.github.io/diplomacyR/reference/dp_advance.md),
[`dp_build()`](https://r-heller.github.io/diplomacyR/reference/dp_build.md),
[`dp_play()`](https://r-heller.github.io/diplomacyR/reference/dp_play.md),
[`dp_result`](https://r-heller.github.io/diplomacyR/reference/dp_result.md),
[`dp_step()`](https://r-heller.github.io/diplomacyR/reference/dp_step.md),
[`is_dp_result()`](https://r-heller.github.io/diplomacyR/reference/is_dp_result.md)

## Examples

``` r
g <- dp_example_game("retreat")
dp_retreat(g, "Austria: A Tri R Alb")
#> <dp_result> Spring 1902 (retreat phase)
#> • 1 of 1 order succeeded
#> • 0 units dislodged
#> • 0 provinces left contested
```
