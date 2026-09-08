# Start a new standard Diplomacy game

Initialises a game in the Spring 1901 movement phase with the canonical
opening position: 22 units across the seven Great Powers, each power
owning its home supply centres.

## Usage

``` r
dp_new_game(map = dp_map(), year = 1901, call = rlang::caller_env())
```

## Arguments

- map:

  A [dp_map](https://r-heller.github.io/diplomacyR/reference/dp_map.md)
  object. Defaults to the standard board.

- year:

  Starting year. Default `1901`.

- call:

  Caller environment, for error reporting. Experts only.

## Value

A [dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
object in the Spring movement phase.

## See also

Other setup:
[`dp_adjacent()`](https://r-heller.github.io/diplomacyR/reference/dp_adjacent.md),
[`dp_example_game()`](https://r-heller.github.io/diplomacyR/reference/dp_example_game.md),
[`dp_game`](https://r-heller.github.io/diplomacyR/reference/dp_game.md),
[`dp_game_from_units()`](https://r-heller.github.io/diplomacyR/reference/dp_game_from_units.md),
[`dp_home_centres()`](https://r-heller.github.io/diplomacyR/reference/dp_home_centres.md),
[`dp_map()`](https://r-heller.github.io/diplomacyR/reference/dp_map.md),
[`dp_map-class`](https://r-heller.github.io/diplomacyR/reference/dp_map-class.md),
[`dp_provinces()`](https://r-heller.github.io/diplomacyR/reference/dp_provinces.md),
[`dp_unit()`](https://r-heller.github.io/diplomacyR/reference/dp_unit.md),
[`dp_units()`](https://r-heller.github.io/diplomacyR/reference/dp_units.md),
[`is_dp_game()`](https://r-heller.github.io/diplomacyR/reference/is_dp_game.md),
[`is_dp_map()`](https://r-heller.github.io/diplomacyR/reference/is_dp_map.md)

## Examples

``` r
g <- dp_new_game()
g
#> <dp_game> Spring 1901 (movement phase)
#> Russia    4 centres   4 units
#> Austria   3 centres   3 units
#> England   3 centres   3 units
#> France    3 centres   3 units
#> Germany   3 centres   3 units
#> Italy     3 centres   3 units
#> Turkey    3 centres   3 units
nrow(g$units)
#> [1] 22
```
