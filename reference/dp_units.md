# Units currently on the board

Units currently on the board

## Usage

``` r
dp_units(game, power = NULL)
```

## Arguments

- game:

  A
  [dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
  object.

- power:

  Optional power to filter on.

## Value

A tibble with columns `power`, `type`, `loc` and `province`.

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
[`is_dp_game()`](https://r-heller.github.io/diplomacyR/reference/is_dp_game.md),
[`is_dp_map()`](https://r-heller.github.io/diplomacyR/reference/is_dp_map.md)

## Examples

``` r
dp_units(dp_new_game(), "Italy")
#> # A tibble: 3 × 4
#>   power type  loc   province
#>   <chr> <chr> <chr> <chr>   
#> 1 Italy fleet nap   nap     
#> 2 Italy army  rom   rom     
#> 3 Italy army  ven   ven     
```
