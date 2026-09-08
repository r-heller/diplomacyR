# Example order sets

Complete, legal order sets that go with
[`dp_example_game()`](https://r-heller.github.io/diplomacyR/reference/dp_example_game.md).

## Usage

``` r
dp_example_orders(
  phase = c("spring_1901", "fall_1901", "retreat", "build"),
  map = dp_map()
)
```

## Arguments

- phase:

  Which set to build:

  - `"spring_1901"` – a plausible opening for all seven powers.

  - `"fall_1901"` – a follow-up set for the same position.

  - `"retreat"` – the retreat that goes with
    `dp_example_game("retreat")`.

  - `"build"` – the adjustments that go with `dp_example_game("build")`.

- map:

  A [dp_map](https://r-heller.github.io/diplomacyR/reference/dp_map.md)
  object.

## Value

A `dp_orders` tibble.

## See also

Other orders:
[`as_tibble.dp_orders()`](https://r-heller.github.io/diplomacyR/reference/as_tibble.dp_orders.md),
[`dp_bind_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_bind_orders.md),
[`dp_legal_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_legal_orders.md),
[`dp_order()`](https://r-heller.github.io/diplomacyR/reference/dp_order.md),
[`dp_orders`](https://r-heller.github.io/diplomacyR/reference/dp_orders.md),
[`dp_parse_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_parse_orders.md),
[`format.dp_orders()`](https://r-heller.github.io/diplomacyR/reference/format.dp_orders.md),
[`is_dp_orders()`](https://r-heller.github.io/diplomacyR/reference/is_dp_orders.md)

## Examples

``` r
dp_example_orders("spring_1901")
#> <dp_orders> (22 orders)
#> Austria: A Vie - Tri
#> Austria: A Bud - Ser
#> Austria: F Tri - Alb
#> England: F Lon - Nth
#> England: F Edi - Nwg
#> England: A Lvp - Yor
#> France: A Par - Bur
#> France: A Mar - Spa
#> France: F Bre - Mao
#> Germany: A Ber - Kie
#> Germany: A Mun - Ruh
#> Germany: F Kie - Den
#> Italy: A Ven - Pie
#> Italy: A Rom - Ven
#> Italy: F Nap - Ion
#> Russia: A Mos - Ukr
#> Russia: A War - Gal
#> Russia: F Sev - Bla
#> Russia: F Stp/sc - Bot
#> Turkey: F Ank - Bla
#> ... and 2 more
```
