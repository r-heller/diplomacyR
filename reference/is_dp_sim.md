# Test whether an object is a simulation result

Test whether an object is a simulation result

## Usage

``` r
is_dp_sim(x)
```

## Arguments

- x:

  An object to test.

## Value

A logical scalar.

## See also

Other simulation:
[`dp_sim`](https://r-heller.github.io/diplomacyR/reference/dp_sim.md),
[`dp_simulate()`](https://r-heller.github.io/diplomacyR/reference/dp_simulate.md),
[`dp_stats()`](https://r-heller.github.io/diplomacyR/reference/dp_stats.md)

## Examples

``` r
is_dp_sim(dp_simulate(n = 1, bots = "hold", max_years = 1, verbose = FALSE))
#> [1] TRUE
```
