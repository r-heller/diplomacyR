# Describe a unit

Builds the one-row tibble the package uses to represent a single army or
fleet. Fleets on a split-coast province must give the coast explicitly,
for example `"spa/nc"`; if the coast is omitted and the province has
exactly one coast reachable in the board graph, it is filled in.

## Usage

``` r
dp_unit(power, type, loc, map = dp_map(), call = rlang::caller_env())
```

## Arguments

- power:

  Owning power, for example `"France"`.

- type:

  `"army"` or `"fleet"`.

- loc:

  Location code, for example `"par"` or `"spa/nc"`.

- map:

  A [dp_map](https://r-heller.github.io/diplomacyR/reference/dp_map.md)
  object used to validate the location.

- call:

  Caller environment, for error reporting. Experts only.

## Value

A one-row tibble with columns `power`, `type` and `loc`.

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
[`dp_units()`](https://r-heller.github.io/diplomacyR/reference/dp_units.md),
[`is_dp_game()`](https://r-heller.github.io/diplomacyR/reference/is_dp_game.md),
[`is_dp_map()`](https://r-heller.github.io/diplomacyR/reference/is_dp_map.md)

## Examples

``` r
dp_unit("France", "army", "par")
#> # A tibble: 1 × 3
#>   power  type  loc  
#>   <chr>  <chr> <chr>
#> 1 France army  par  
dp_unit("Russia", "fleet", "stp/sc")
#> # A tibble: 1 × 3
#>   power  type  loc   
#>   <chr>  <chr> <chr> 
#> 1 Russia fleet stp/sc
```
