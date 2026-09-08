# Render orders as standard notation

Render orders as standard notation

## Usage

``` r
# S3 method for class 'dp_orders'
format(x, ...)
```

## Arguments

- x:

  A `dp_orders` tibble.

- ...:

  Ignored.

## Value

A character vector, one canonical order string per row.

## See also

Other orders:
[`as_tibble.dp_orders()`](https://r-heller.github.io/diplomacyR/reference/as_tibble.dp_orders.md),
[`dp_bind_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_bind_orders.md),
[`dp_example_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_example_orders.md),
[`dp_legal_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_legal_orders.md),
[`dp_order()`](https://r-heller.github.io/diplomacyR/reference/dp_order.md),
[`dp_orders`](https://r-heller.github.io/diplomacyR/reference/dp_orders.md),
[`dp_parse_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_parse_orders.md),
[`is_dp_orders()`](https://r-heller.github.io/diplomacyR/reference/is_dp_orders.md)

## Examples

``` r
format(dp_parse_orders("France: A Par - Bur"))
#> [1] "France: A Par - Bur"
```
