# A set of orders

A `dp_orders` object is a tibble with one row per order, subclassed so
that [`format()`](https://rdrr.io/r/base/format.html) renders it back to
standard notation. Build one with
[`dp_order()`](https://r-heller.github.io/diplomacyR/reference/dp_order.md),
[`dp_parse_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_parse_orders.md)
or
[`dp_legal_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_legal_orders.md).

## Details

The columns are `power`, `type` (one of `"hold"`, `"move"`, `"support"`,
`"convoy"`, `"retreat"`, `"build"`, `"disband"`, `"waive"`),
`unit_type`, `loc`, `target`, `aux_type`, `aux_loc`, `aux_target` and
`via_convoy`. The `aux_*` columns describe the order being supported or
convoyed. After adjudication the tibble gains a `success` column and a
`note` explaining anything the rules changed.

## See also

[`dp_order()`](https://r-heller.github.io/diplomacyR/reference/dp_order.md),
[`dp_parse_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_parse_orders.md),
[`format.dp_orders()`](https://r-heller.github.io/diplomacyR/reference/format.dp_orders.md)

Other orders:
[`as_tibble.dp_orders()`](https://r-heller.github.io/diplomacyR/reference/as_tibble.dp_orders.md),
[`dp_bind_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_bind_orders.md),
[`dp_example_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_example_orders.md),
[`dp_legal_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_legal_orders.md),
[`dp_order()`](https://r-heller.github.io/diplomacyR/reference/dp_order.md),
[`dp_parse_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_parse_orders.md),
[`format.dp_orders()`](https://r-heller.github.io/diplomacyR/reference/format.dp_orders.md),
[`is_dp_orders()`](https://r-heller.github.io/diplomacyR/reference/is_dp_orders.md)

## Examples

``` r
o <- dp_parse_orders("France: A Par - Bur")
names(o)
#> [1] "power"      "type"       "unit_type"  "loc"        "target"    
#> [6] "aux_type"   "aux_loc"    "aux_target" "via_convoy"
```
