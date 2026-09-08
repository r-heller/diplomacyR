# Load a Diplomacy board

Reads a board definition shipped with the package and returns it as a
validated `dp_map` object. Only the standard seven-power pre-1914 map is
currently supplied: 75 provinces (56 land, 19 sea), 34 supply centres
and the canonical 22-unit opening position.

## Usage

``` r
dp_map(name = "standard", call = rlang::caller_env())
```

## Arguments

- name:

  Board to load. Only `"standard"` is available.

- call:

  Caller environment, for error reporting. Experts only.

## Value

A dp_map object: a list with the province table, the army and fleet
adjacency graphs, supply-centre and home-centre definitions, and the
starting position.

## See also

Other setup:
[`dp_adjacent()`](https://r-heller.github.io/diplomacyR/reference/dp_adjacent.md),
[`dp_example_game()`](https://r-heller.github.io/diplomacyR/reference/dp_example_game.md),
[`dp_game`](https://r-heller.github.io/diplomacyR/reference/dp_game.md),
[`dp_game_from_units()`](https://r-heller.github.io/diplomacyR/reference/dp_game_from_units.md),
[`dp_home_centres()`](https://r-heller.github.io/diplomacyR/reference/dp_home_centres.md),
[`dp_map-class`](https://r-heller.github.io/diplomacyR/reference/dp_map-class.md),
[`dp_new_game()`](https://r-heller.github.io/diplomacyR/reference/dp_new_game.md),
[`dp_provinces()`](https://r-heller.github.io/diplomacyR/reference/dp_provinces.md),
[`dp_unit()`](https://r-heller.github.io/diplomacyR/reference/dp_unit.md),
[`dp_units()`](https://r-heller.github.io/diplomacyR/reference/dp_units.md),
[`is_dp_game()`](https://r-heller.github.io/diplomacyR/reference/is_dp_game.md),
[`is_dp_map()`](https://r-heller.github.io/diplomacyR/reference/is_dp_map.md)

## Examples

``` r
m <- dp_map()
m
#> <dp_map> "standard"
#> • 75 provinces (14 inland, 42 coastal, 19 sea)
#> • 34 supply centres, 22 starting units
#> • 7 powers: "Austria", "England", "France", "Germany", "Italy", "Russia", and
#>   "Turkey"
nrow(dp_provinces(m))
#> [1] 75
```
