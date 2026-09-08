# The outcome of a phase

A `dp_result` records what a phase did.
[`dp_adjudicate()`](https://r-heller.github.io/diplomacyR/reference/dp_adjudicate.md),
[`dp_retreat()`](https://r-heller.github.io/diplomacyR/reference/dp_retreat.md)
and
[`dp_build()`](https://r-heller.github.io/diplomacyR/reference/dp_build.md)
all return one, and
[`dp_advance()`](https://r-heller.github.io/diplomacyR/reference/dp_advance.md)
consumes it to produce the next
[dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md).

## Details

- `orders`:

  The effective orders as a
  [dp_orders](https://r-heller.github.io/diplomacyR/reference/dp_orders.md)
  tibble, with a `success` flag and a `note` per order.

- `units`:

  Unit positions after the phase.

- `dislodged`:

  Units dislodged by the phase, with the province the attack came from.

- `contested`:

  Provinces where a standoff occurred.

- `disbanded`:

  Units removed from the board.

- `built`:

  Units added to the board.

- `season`, `year`, `phase`:

  The turn that was resolved.

## See also

[`dp_adjudicate()`](https://r-heller.github.io/diplomacyR/reference/dp_adjudicate.md),
[`dp_advance()`](https://r-heller.github.io/diplomacyR/reference/dp_advance.md),
[`is_dp_result()`](https://r-heller.github.io/diplomacyR/reference/is_dp_result.md)

Other engine:
[`dp_adjudicate()`](https://r-heller.github.io/diplomacyR/reference/dp_adjudicate.md),
[`dp_advance()`](https://r-heller.github.io/diplomacyR/reference/dp_advance.md),
[`dp_build()`](https://r-heller.github.io/diplomacyR/reference/dp_build.md),
[`dp_play()`](https://r-heller.github.io/diplomacyR/reference/dp_play.md),
[`dp_retreat()`](https://r-heller.github.io/diplomacyR/reference/dp_retreat.md),
[`dp_step()`](https://r-heller.github.io/diplomacyR/reference/dp_step.md),
[`is_dp_result()`](https://r-heller.github.io/diplomacyR/reference/is_dp_result.md)

## Examples

``` r
res <- dp_adjudicate(dp_new_game(), dp_example_orders())
res$contested
#> [1] "bla"
```
