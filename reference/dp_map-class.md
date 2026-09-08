# The board

A `dp_map` is the province graph a game is played on, loaded with
[`dp_map()`](https://r-heller.github.io/diplomacyR/reference/dp_map.md).
It holds the province table, separate adjacency graphs for armies and
for fleets, the supply centres and home centres, and the canonical
opening position. The two graphs are what makes coasts work: armies move
over provinces, fleets move over coasts, and a split-coast province such
as Spain appears in the fleet graph only as `"spa/nc"` and `"spa/sc"`.

## See also

[`dp_map()`](https://r-heller.github.io/diplomacyR/reference/dp_map.md),
[`dp_provinces()`](https://r-heller.github.io/diplomacyR/reference/dp_provinces.md),
[`dp_adjacent()`](https://r-heller.github.io/diplomacyR/reference/dp_adjacent.md)

Other setup:
[`dp_adjacent()`](https://r-heller.github.io/diplomacyR/reference/dp_adjacent.md),
[`dp_example_game()`](https://r-heller.github.io/diplomacyR/reference/dp_example_game.md),
[`dp_game`](https://r-heller.github.io/diplomacyR/reference/dp_game.md),
[`dp_game_from_units()`](https://r-heller.github.io/diplomacyR/reference/dp_game_from_units.md),
[`dp_home_centres()`](https://r-heller.github.io/diplomacyR/reference/dp_home_centres.md),
[`dp_map()`](https://r-heller.github.io/diplomacyR/reference/dp_map.md),
[`dp_new_game()`](https://r-heller.github.io/diplomacyR/reference/dp_new_game.md),
[`dp_provinces()`](https://r-heller.github.io/diplomacyR/reference/dp_provinces.md),
[`dp_unit()`](https://r-heller.github.io/diplomacyR/reference/dp_unit.md),
[`dp_units()`](https://r-heller.github.io/diplomacyR/reference/dp_units.md),
[`is_dp_game()`](https://r-heller.github.io/diplomacyR/reference/is_dp_game.md),
[`is_dp_map()`](https://r-heller.github.io/diplomacyR/reference/is_dp_map.md)

## Examples

``` r
m <- dp_map()
m$provinces[1:3, ]
#> # A tibble: 3 × 7
#>   code  name         type  supply_centre home_power     x     y
#>   <chr> <chr>        <chr> <lgl>         <chr>      <dbl> <dbl>
#> 1 adr   Adriatic Sea sea   FALSE         NA            47    48
#> 2 aeg   Aegean Sea   sea   FALSE         NA            59    41
#> 3 alb   Albania      coast FALSE         NA            51    48
m$fleet_adj[["spa/nc"]]
#> [1] "gas" "mao" "por"
```
