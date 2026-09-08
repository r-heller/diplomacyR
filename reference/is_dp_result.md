# Test whether an object is an adjudication result

Test whether an object is an adjudication result

## Usage

``` r
is_dp_result(x)
```

## Arguments

- x:

  An object to test.

## Value

A logical scalar.

## See also

Other engine:
[`dp_adjudicate()`](https://r-heller.github.io/diplomacyR/reference/dp_adjudicate.md),
[`dp_advance()`](https://r-heller.github.io/diplomacyR/reference/dp_advance.md),
[`dp_build()`](https://r-heller.github.io/diplomacyR/reference/dp_build.md),
[`dp_play()`](https://r-heller.github.io/diplomacyR/reference/dp_play.md),
[`dp_result`](https://r-heller.github.io/diplomacyR/reference/dp_result.md),
[`dp_retreat()`](https://r-heller.github.io/diplomacyR/reference/dp_retreat.md),
[`dp_step()`](https://r-heller.github.io/diplomacyR/reference/dp_step.md)

## Examples

``` r
is_dp_result(dp_adjudicate(dp_new_game(), dp_example_orders()))
#> [1] TRUE
```
