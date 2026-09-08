# Build a game state from an explicit position

Convenience constructor used by the test suites and by the Shiny board
editor: places the given units on the board and fills supply-centre
ownership from the home centres unless `sc_owner` says otherwise.

## Usage

``` r
dp_game_from_units(
  units,
  map = dp_map(),
  season = "Spring",
  year = 1901,
  phase = "movement",
  sc_owner = NULL,
  dislodged = NULL,
  contested = character(0),
  call = rlang::caller_env()
)
```

## Arguments

- units:

  A tibble or data frame with columns `power`, `type`, `loc`.

- map:

  A [dp_map](https://r-heller.github.io/diplomacyR/reference/dp_map.md)
  object.

- season:

  `"Spring"`, `"Fall"` or `"Winter"`.

- year:

  Integer year.

- phase:

  `"movement"`, `"retreat"` or `"build"`.

- sc_owner:

  Optional named character vector mapping supply centre to owning power.
  Defaults to home ownership.

- dislodged:

  Optional tibble of dislodged units awaiting retreat, with columns
  `power`, `type`, `loc`, `from` and `by_convoy`.

- contested:

  Provinces closed to retreats after a standoff.

- call:

  Caller environment, for error reporting. Experts only.

## Value

A validated
[dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
object.

## See also

Other setup:
[`dp_adjacent()`](https://r-heller.github.io/diplomacyR/reference/dp_adjacent.md),
[`dp_example_game()`](https://r-heller.github.io/diplomacyR/reference/dp_example_game.md),
[`dp_game`](https://r-heller.github.io/diplomacyR/reference/dp_game.md),
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
pos <- data.frame(
  power = c("France", "Germany"),
  type = c("army", "army"),
  loc = c("par", "mun")
)
dp_game_from_units(pos)
#> <dp_game> Spring 1901 (movement phase)
#> Russia    4 centres   0 units
#> Austria   3 centres   0 units
#> England   3 centres   0 units
#> France    3 centres   1 unit 
#> Germany   3 centres   1 unit 
#> Italy     3 centres   0 units
#> Turkey    3 centres   0 units
```
