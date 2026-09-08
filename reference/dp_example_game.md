# Example game positions

Ready-made board states for documentation, tests and the Shiny app.

## Usage

``` r
dp_example_game(
  state = c("opening", "midgame", "retreat", "build", "solo"),
  map = dp_map()
)
```

## Arguments

- state:

  Which position to build:

  - `"opening"` – Spring 1901, the canonical starting position.

  - `"midgame"` – a contested Fall 1903 position.

  - `"retreat"` – a retreat phase with one dislodged fleet.

  - `"build"` – an adjustment phase with builds and a disband due.

  - `"solo"` – a position in which one power holds 18 centres.

- map:

  A [dp_map](https://r-heller.github.io/diplomacyR/reference/dp_map.md)
  object.

## Value

A [dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
object.

## See also

Other setup:
[`dp_adjacent()`](https://r-heller.github.io/diplomacyR/reference/dp_adjacent.md),
[`dp_game`](https://r-heller.github.io/diplomacyR/reference/dp_game.md),
[`dp_game_from_units()`](https://r-heller.github.io/diplomacyR/reference/dp_game_from_units.md),
[`dp_home_centres()`](https://r-heller.github.io/diplomacyR/reference/dp_home_centres.md),
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
dp_example_game()
#> <dp_game> Spring 1901 (movement phase)
#> Russia    4 centres   4 units
#> Austria   3 centres   3 units
#> England   3 centres   3 units
#> France    3 centres   3 units
#> Germany   3 centres   3 units
#> Italy     3 centres   3 units
#> Turkey    3 centres   3 units
dp_example_game("retreat")
#> <dp_game> Spring 1902 (retreat phase)
#> Russia    4 centres   0 units
#> Austria   3 centres   2 units
#> England   3 centres   0 units
#> France    3 centres   0 units
#> Germany   3 centres   0 units
#> Italy     3 centres   2 units
#> Turkey    3 centres   0 units
#> ! 1 dislodged unit awaiting retreat.
```
