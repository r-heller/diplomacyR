# Test whether an object is an orders tibble

Test whether an object is an orders tibble

## Usage

``` r
is_dp_orders(x)
```

## Arguments

- x:

  An object to test.

## Value

A logical scalar.

## See also

Other orders:
[`as_tibble.dp_orders()`](https://r-heller.github.io/diplomacyR/reference/as_tibble.dp_orders.md),
[`dp_bind_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_bind_orders.md),
[`dp_example_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_example_orders.md),
[`dp_legal_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_legal_orders.md),
[`dp_order()`](https://r-heller.github.io/diplomacyR/reference/dp_order.md),
[`dp_orders`](https://r-heller.github.io/diplomacyR/reference/dp_orders.md),
[`dp_parse_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_parse_orders.md),
[`format.dp_orders()`](https://r-heller.github.io/diplomacyR/reference/format.dp_orders.md)

## Examples

``` r
is_dp_orders(dp_order("France", "hold", "par"))
#> [1] TRUE
```
