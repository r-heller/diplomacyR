# Coerce orders to a tibble

Coerce orders to a tibble

## Usage

``` r
# S3 method for class 'dp_orders'
as_tibble(x, ...)
```

## Arguments

- x:

  A `dp_orders` object.

- ...:

  Ignored.

## Value

A plain tibble with the order columns.

## See also

Other orders:
[`dp_bind_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_bind_orders.md),
[`dp_example_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_example_orders.md),
[`dp_legal_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_legal_orders.md),
[`dp_order()`](https://r-heller.github.io/diplomacyR/reference/dp_order.md),
[`dp_orders`](https://r-heller.github.io/diplomacyR/reference/dp_orders.md),
[`dp_parse_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_parse_orders.md),
[`format.dp_orders()`](https://r-heller.github.io/diplomacyR/reference/format.dp_orders.md),
[`is_dp_orders()`](https://r-heller.github.io/diplomacyR/reference/is_dp_orders.md)

## Examples

``` r
as_tibble(dp_example_orders())
#> # A tibble: 22 × 9
#>    power   type  unit_type loc   target aux_type aux_loc aux_target via_convoy
#>    <chr>   <chr> <chr>     <chr> <chr>  <chr>    <chr>   <chr>      <lgl>     
#>  1 Austria move  army      vie   tri    NA       NA      NA         FALSE     
#>  2 Austria move  army      bud   ser    NA       NA      NA         FALSE     
#>  3 Austria move  fleet     tri   alb    NA       NA      NA         FALSE     
#>  4 England move  fleet     lon   nth    NA       NA      NA         FALSE     
#>  5 England move  fleet     edi   nwg    NA       NA      NA         FALSE     
#>  6 England move  army      lvp   yor    NA       NA      NA         FALSE     
#>  7 France  move  army      par   bur    NA       NA      NA         FALSE     
#>  8 France  move  army      mar   spa    NA       NA      NA         FALSE     
#>  9 France  move  fleet     bre   mao    NA       NA      NA         FALSE     
#> 10 Germany move  army      ber   kie    NA       NA      NA         FALSE     
#> # ℹ 12 more rows
```
