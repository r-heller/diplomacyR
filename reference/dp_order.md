# Construct a Diplomacy order

Builds a single order as a one-row `dp_orders` tibble. Orders are
combined with [`rbind()`](https://rdrr.io/r/base/cbind.html) or
[`dp_bind_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_bind_orders.md),
and rendered back to standard notation by
[`format()`](https://rdrr.io/r/base/format.html).

## Usage

``` r
dp_order(
  power,
  type,
  unit = NULL,
  target = NULL,
  aux = NULL,
  unit_type = NULL,
  aux_type = NULL,
  via_convoy = FALSE,
  map = dp_map(),
  call = rlang::caller_env()
)
```

## Arguments

- power:

  Ordering power, for example `"France"`.

- type:

  One of `"hold"`, `"move"`, `"support"`, `"convoy"`, `"retreat"`,
  `"build"`, `"disband"` or `"waive"`.

- unit:

  Location of the ordered unit, for example `"par"` or `"spa/nc"`.
  Ignored for `"waive"`.

- target:

  Destination province for moves, retreats and builds, or `NULL`.

- aux:

  For supports and convoys, the order being supported or convoyed:
  either a single province (a unit ordered to hold) or a length-2 vector
  `c(from, to)`, or the string `"from-to"`.

- unit_type:

  `"army"` or `"fleet"`. Required for builds; otherwise inferred from
  `map` when possible.

- aux_type:

  `"army"` or `"fleet"` for the supported or convoyed unit.

- via_convoy:

  Force a move to be routed by convoy. Default `FALSE`.

- map:

  A [dp_map](https://r-heller.github.io/diplomacyR/reference/dp_map.md)
  object used to validate locations.

- call:

  Caller environment, for error reporting. Experts only.

## Value

A one-row `dp_orders` tibble with columns `power`, `type`, `unit_type`,
`loc`, `target`, `aux_type`, `aux_loc`, `aux_target` and `via_convoy`.

## See also

Other orders:
[`as_tibble.dp_orders()`](https://r-heller.github.io/diplomacyR/reference/as_tibble.dp_orders.md),
[`dp_bind_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_bind_orders.md),
[`dp_example_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_example_orders.md),
[`dp_legal_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_legal_orders.md),
[`dp_orders`](https://r-heller.github.io/diplomacyR/reference/dp_orders.md),
[`dp_parse_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_parse_orders.md),
[`format.dp_orders()`](https://r-heller.github.io/diplomacyR/reference/format.dp_orders.md),
[`is_dp_orders()`](https://r-heller.github.io/diplomacyR/reference/is_dp_orders.md)

## Examples

``` r
dp_order("France", "move", "par", target = "bur")
#> <dp_orders> (1 order)
#> France: A Par - Bur
dp_order("England", "support", "lon", aux = c("wal", "yor"))
#> <dp_orders> (1 order)
#> England: Lon S Wal - Yor
dp_order("England", "convoy", "nth", aux = "lon-nwy")
#> <dp_orders> (1 order)
#> England: F Nth C Lon - Nwy
```
