# The game state

A `dp_game` is one position on the board at one moment: who has what
where, who owns which supply centres, and which phase of which year it
is. Build one with
[`dp_new_game()`](https://r-heller.github.io/diplomacyR/reference/dp_new_game.md),
[`dp_game_from_units()`](https://r-heller.github.io/diplomacyR/reference/dp_game_from_units.md)
or
[`dp_example_game()`](https://r-heller.github.io/diplomacyR/reference/dp_example_game.md),
and step it forward with
[`dp_step()`](https://r-heller.github.io/diplomacyR/reference/dp_step.md)
or
[`dp_advance()`](https://r-heller.github.io/diplomacyR/reference/dp_advance.md).

## Details

A `dp_game` is a list with these elements:

- `map`:

  The
  [dp_map](https://r-heller.github.io/diplomacyR/reference/dp_map.md)
  the game is played on.

- `units`:

  A tibble of the units on the board, with columns `power`, `type`
  (`"army"` or `"fleet"`) and `loc`. Fleets on a split-coast province
  carry the coast, as in `"stp/sc"`.

- `sc_owner`:

  A named character vector mapping supply centre to the power that owns
  it.

- `season`:

  `"Spring"`, `"Fall"` or `"Winter"`.

- `year`:

  The game year, an integer.

- `phase`:

  `"movement"`, `"retreat"` or `"build"`.

- `powers`:

  The powers in the game.

- `dislodged`:

  A tibble of units awaiting a retreat, with columns `power`, `type`,
  `loc`, `from` (the province the attack came from) and `by_convoy`.

- `contested`:

  Provinces left empty by a standoff, which are closed to retreats.

- `status`:

  A list recording the `winner`, the `outcome` and whether the game is
  `over`.

## See also

[`dp_new_game()`](https://r-heller.github.io/diplomacyR/reference/dp_new_game.md),
[`dp_game_from_units()`](https://r-heller.github.io/diplomacyR/reference/dp_game_from_units.md),
[`is_dp_game()`](https://r-heller.github.io/diplomacyR/reference/is_dp_game.md)

Other setup:
[`dp_adjacent()`](https://r-heller.github.io/diplomacyR/reference/dp_adjacent.md),
[`dp_example_game()`](https://r-heller.github.io/diplomacyR/reference/dp_example_game.md),
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
g <- dp_new_game()
g$season
#> [1] "Spring"
head(g$units)
#> # A tibble: 6 × 3
#>   power   type  loc  
#>   <chr>   <chr> <chr>
#> 1 Austria army  bud  
#> 2 Austria army  vie  
#> 3 Austria fleet tri  
#> 4 England fleet edi  
#> 5 England fleet lon  
#> 6 England army  lvp  
```
