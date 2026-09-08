# Test whether an object is a game

Test whether an object is a game

## Usage

``` r
is_dp_game(x)
```

## Arguments

- x:

  An object to test.

## Value

A logical scalar.

## See also

Other setup:
[`dp_adjacent()`](https://r-heller.github.io/diplomacyR/reference/dp_adjacent.md),
[`dp_example_game()`](https://r-heller.github.io/diplomacyR/reference/dp_example_game.md),
[`dp_game`](https://r-heller.github.io/diplomacyR/reference/dp_game.md),
[`dp_game_from_units()`](https://r-heller.github.io/diplomacyR/reference/dp_game_from_units.md),
[`dp_home_centres()`](https://r-heller.github.io/diplomacyR/reference/dp_home_centres.md),
[`dp_map()`](https://r-heller.github.io/diplomacyR/reference/dp_map.md),
[`dp_map-class`](https://r-heller.github.io/diplomacyR/reference/dp_map-class.md),
[`dp_new_game()`](https://r-heller.github.io/diplomacyR/reference/dp_new_game.md),
[`dp_provinces()`](https://r-heller.github.io/diplomacyR/reference/dp_provinces.md),
[`dp_unit()`](https://r-heller.github.io/diplomacyR/reference/dp_unit.md),
[`dp_units()`](https://r-heller.github.io/diplomacyR/reference/dp_units.md),
[`is_dp_map()`](https://r-heller.github.io/diplomacyR/reference/is_dp_map.md)

## Examples

``` r
is_dp_game(dp_new_game())
#> [1] TRUE
```
