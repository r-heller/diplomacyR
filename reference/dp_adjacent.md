# Neighbours of a location

Returns the locations a unit of the given type may move to in one step.
For fleets, split-coast provinces are addressed by their named coasts
(`"spa/nc"`, `"bul/ec"`, `"stp/sc"`, ...).

## Usage

``` r
dp_adjacent(
  map,
  loc,
  unit_type = c("army", "fleet"),
  call = rlang::caller_env()
)
```

## Arguments

- map:

  A [dp_map](https://r-heller.github.io/diplomacyR/reference/dp_map.md)
  object.

- loc:

  A location code, such as `"par"` or `"spa/nc"`.

- unit_type:

  `"army"` or `"fleet"`.

- call:

  Caller environment, for error reporting. Experts only.

## Value

A character vector of neighbouring locations, possibly empty.

## See also

Other setup:
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
[`is_dp_game()`](https://r-heller.github.io/diplomacyR/reference/is_dp_game.md),
[`is_dp_map()`](https://r-heller.github.io/diplomacyR/reference/is_dp_map.md)

## Examples

``` r
dp_adjacent(dp_map(), "par", "army")
#> [1] "bre" "bur" "gas" "pic"
dp_adjacent(dp_map(), "spa/nc", "fleet")
#> [1] "gas" "mao" "por"
```
