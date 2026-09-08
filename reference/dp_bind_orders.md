# Combine orders

Combine orders

## Usage

``` r
dp_bind_orders(...)
```

## Arguments

- ...:

  `dp_orders` tibbles to stack, in order.

## Value

A `dp_orders` tibble containing every input row.

## See also

Other orders:
[`as_tibble.dp_orders()`](https://r-heller.github.io/diplomacyR/reference/as_tibble.dp_orders.md),
[`dp_example_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_example_orders.md),
[`dp_legal_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_legal_orders.md),
[`dp_order()`](https://r-heller.github.io/diplomacyR/reference/dp_order.md),
[`dp_orders`](https://r-heller.github.io/diplomacyR/reference/dp_orders.md),
[`dp_parse_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_parse_orders.md),
[`format.dp_orders()`](https://r-heller.github.io/diplomacyR/reference/format.dp_orders.md),
[`is_dp_orders()`](https://r-heller.github.io/diplomacyR/reference/is_dp_orders.md)

## Examples

``` r
a <- dp_order("France", "move", "par", target = "bur")
b <- dp_order("France", "hold", "mar")
dp_bind_orders(a, b)
#> <dp_orders> (2 orders)
#> France: A Par - Bur
#> France: Mar H
```
