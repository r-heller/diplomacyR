# List the provinces of a board

List the provinces of a board

## Usage

``` r
dp_provinces(map = dp_map(), type = NULL)
```

## Arguments

- map:

  A [dp_map](https://r-heller.github.io/diplomacyR/reference/dp_map.md)
  object.

- type:

  Optional filter: one or more of `"land"`, `"coast"`, `"sea"`.

## Value

A tibble with one row per province and columns `code`, `name`, `type`,
`supply_centre`, `home_power`, `x` and `y`.

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
[`dp_unit()`](https://r-heller.github.io/diplomacyR/reference/dp_unit.md),
[`dp_units()`](https://r-heller.github.io/diplomacyR/reference/dp_units.md),
[`is_dp_game()`](https://r-heller.github.io/diplomacyR/reference/is_dp_game.md),
[`is_dp_map()`](https://r-heller.github.io/diplomacyR/reference/is_dp_map.md)

## Examples

``` r
dp_provinces(dp_map(), type = "sea")
#> # A tibble: 19 × 7
#>    code  name                  type  supply_centre home_power     x     y
#>    <chr> <chr>                 <chr> <lgl>         <chr>      <dbl> <dbl>
#>  1 adr   Adriatic Sea          sea   FALSE         NA            47    48
#>  2 aeg   Aegean Sea            sea   FALSE         NA            59    41
#>  3 bal   Baltic Sea            sea   FALSE         NA            48    74
#>  4 bar   Barents Sea           sea   FALSE         NA            55    97
#>  5 bla   Black Sea             sea   FALSE         NA            65    55
#>  6 bot   Gulf of Bothnia       sea   FALSE         NA            50    80
#>  7 eas   Eastern Mediterranean sea   FALSE         NA            66    34
#>  8 eng   English Channel       sea   FALSE         NA            19    70
#>  9 hel   Helgoland Bight       sea   FALSE         NA            36    74
#> 10 ion   Ionian Sea            sea   FALSE         NA            50    34
#> 11 iri   Irish Sea             sea   FALSE         NA            14    76
#> 12 lyo   Gulf of Lyon          sea   FALSE         NA            33    44
#> 13 mao   Mid-Atlantic Ocean    sea   FALSE         NA            10    55
#> 14 nao   North Atlantic Ocean  sea   FALSE         NA            10    88
#> 15 nth   North Sea             sea   FALSE         NA            29    79
#> 16 nwg   Norwegian Sea         sea   FALSE         NA            30    92
#> 17 ska   Skagerrak             sea   FALSE         NA            41    78
#> 18 tys   Tyrrhenian Sea        sea   FALSE         NA            44    38
#> 19 wes   Western Mediterranean sea   FALSE         NA            34    36
```
