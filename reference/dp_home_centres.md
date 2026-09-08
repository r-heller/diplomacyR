# Home supply centres

Home supply centres

## Usage

``` r
dp_home_centres(map = dp_map(), power = NULL)
```

## Arguments

- map:

  A [dp_map](https://r-heller.github.io/diplomacyR/reference/dp_map.md)
  object.

- power:

  Optional power to filter on.

## Value

A tibble with columns `power` and `centre`.

## See also

Other setup:
[`dp_adjacent()`](https://r-heller.github.io/diplomacyR/reference/dp_adjacent.md),
[`dp_example_game()`](https://r-heller.github.io/diplomacyR/reference/dp_example_game.md),
[`dp_game`](https://r-heller.github.io/diplomacyR/reference/dp_game.md),
[`dp_game_from_units()`](https://r-heller.github.io/diplomacyR/reference/dp_game_from_units.md),
[`dp_map()`](https://r-heller.github.io/diplomacyR/reference/dp_map.md),
[`dp_map-class`](https://r-heller.github.io/diplomacyR/reference/dp_map-class.md),
[`dp_new_game()`](https://r-heller.github.io/diplomacyR/reference/dp_new_game.md),
[`dp_provinces()`](https://r-heller.github.io/diplomacyR/reference/dp_provinces.md),
[`dp_unit()`](https://r-heller.github.io/diplomacyR/reference/dp_unit.md),
[`dp_units()`](https://r-heller.github.io/diplomacyR/reference/dp_units.md),
[`is_dp_game()`](https://r-heller.github.io/diplomacyR/reference/is_dp_game.md),
[`is_dp_map()`](https://r-heller.github.io/diplomacyR/reference/is_dp_map.md)

## Examples

``` r
dp_home_centres(dp_map(), "France")
#> # A tibble: 3 × 2
#>   power  centre
#>   <chr>  <chr> 
#> 1 France bre   
#> 2 France mar   
#> 3 France par   
```
