# Parse Diplomacy order notation

Reads orders written in standard notation and returns them as a
`dp_orders` tibble. All the usual spellings are accepted, in any case:

## Usage

``` r
dp_parse_orders(
  x,
  power = NULL,
  phase = c("movement", "retreat", "build"),
  map = dp_map(),
  call = rlang::caller_env()
)
```

## Arguments

- x:

  A character vector of orders, one per element. Multi-line strings are
  split on newlines and semicolons.

- power:

  Default power for orders that do not name one.

- phase:

  Phase the orders belong to: `"movement"`, `"retreat"` or `"build"`. A
  bare `"A Tri - Alb"` is a move in a movement phase and a retreat in a
  retreat phase.

- map:

  A [dp_map](https://r-heller.github.io/diplomacyR/reference/dp_map.md)
  object used to validate province codes.

- call:

  Caller environment, for error reporting. Experts only.

## Value

A `dp_orders` tibble with one row per order.

## Details

- `"A Par - Bur"`, `"A Par-Bur"`, `"A Paris to Burgundy"` (move)

- `"A Bur H"`, `"A Bur holds"` (hold)

- `"F Lon S A Wal - Yor"`, `"F Lon supports A Wal"` (support)

- `"F Nth C A Lon - Nwy"` (convoy)

- `"A Lon - Bel via convoy"` (explicitly convoyed move)

- `"A Tri R Alb"` (retreat), `"Build A Par"`, `"Remove F Bre"`,
  `"Waive"`

Each element may be prefixed with the ordering power, as in
`"France: A Par - Bur"`. Otherwise `power` supplies it.

## See also

Other orders:
[`as_tibble.dp_orders()`](https://r-heller.github.io/diplomacyR/reference/as_tibble.dp_orders.md),
[`dp_bind_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_bind_orders.md),
[`dp_example_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_example_orders.md),
[`dp_legal_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_legal_orders.md),
[`dp_order()`](https://r-heller.github.io/diplomacyR/reference/dp_order.md),
[`dp_orders`](https://r-heller.github.io/diplomacyR/reference/dp_orders.md),
[`format.dp_orders()`](https://r-heller.github.io/diplomacyR/reference/format.dp_orders.md),
[`is_dp_orders()`](https://r-heller.github.io/diplomacyR/reference/is_dp_orders.md)

## Examples

``` r
dp_parse_orders(c("France: A Par - Bur", "France: A Mar S A Par - Bur"))
#> <dp_orders> (2 orders)
#> France: A Par - Bur
#> France: A Mar S A Par - Bur
dp_parse_orders("F Nth C A Lon - Nwy", power = "England")
#> <dp_orders> (1 order)
#> England: F Nth C A Lon - Nwy
```
