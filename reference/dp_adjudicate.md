# Adjudicate a movement phase

Resolves every order simultaneously under the standard rules: support
counting and support cutting, convoy path resolution including the
paradox cases, standoffs, dislodgement, and the prohibitions on
self-dislodgement and self-standoff. Units with no order, or with an
order that breaks the rules, hold.

## Usage

``` r
dp_adjudicate(game, orders, call = rlang::caller_env())
```

## Arguments

- game:

  A
  [dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
  object in a movement phase.

- orders:

  A `dp_orders` tibble, or a character vector of orders in standard
  notation.

- call:

  Caller environment, for error reporting. Experts only.

## Value

A
[dp_result](https://r-heller.github.io/diplomacyR/reference/dp_result.md)
object recording, per order, whether it succeeded, plus the resulting
unit positions, the dislodged units and the provinces where a standoff
occurred. Feed it to
[`dp_advance()`](https://r-heller.github.io/diplomacyR/reference/dp_advance.md)
for the next state.

## Details

The implementation follows the Diplomacy Adjudicator Test Cases (DATC);
the encoded cases ship with the package under `extdata/datc`.

## See also

Other engine:
[`dp_advance()`](https://r-heller.github.io/diplomacyR/reference/dp_advance.md),
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
res
#> <dp_result> Spring 1901 (movement phase)
#> • 20 of 22 orders succeeded
#> • 0 units dislodged
#> • 1 province left contested
```
