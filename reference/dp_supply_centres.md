# Supply centres of a board or a game

For a
[dp_map](https://r-heller.github.io/diplomacyR/reference/dp_map.md) this
lists the 34 supply centres of the board. For a
[dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md) it
additionally reports the current owner of each centre and whether it is
occupied.

## Usage

``` r
dp_supply_centres(x, ...)

# S3 method for class 'dp_map'
dp_supply_centres(x, ...)

# S3 method for class 'dp_game'
dp_supply_centres(x, ...)
```

## Arguments

- x:

  A [dp_map](https://r-heller.github.io/diplomacyR/reference/dp_map.md)
  or
  [dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
  object.

- ...:

  Passed to methods.

## Value

A tibble. For a map: `centre`, `name`, `home_power`. For a game:
`centre`, `name`, `home_power`, `owner`, `occupied_by`.

## See also

Other analysis:
[`as_tibble.dp_history()`](https://r-heller.github.io/diplomacyR/reference/as_tibble.dp_history.md),
[`dp_history()`](https://r-heller.github.io/diplomacyR/reference/dp_history.md),
[`dp_history-class`](https://r-heller.github.io/diplomacyR/reference/dp_history-class.md),
[`dp_history_append()`](https://r-heller.github.io/diplomacyR/reference/dp_history_append.md),
[`dp_power_counts()`](https://r-heller.github.io/diplomacyR/reference/dp_power_counts.md),
[`dp_power_summary()`](https://r-heller.github.io/diplomacyR/reference/dp_power_summary.md),
[`dp_sc_trajectory()`](https://r-heller.github.io/diplomacyR/reference/dp_sc_trajectory.md),
[`dp_victory_check()`](https://r-heller.github.io/diplomacyR/reference/dp_victory_check.md),
[`is_dp_history()`](https://r-heller.github.io/diplomacyR/reference/is_dp_history.md)

## Examples

``` r
dp_supply_centres(dp_map())
#> # A tibble: 34 × 3
#>    centre name           home_power
#>    <chr>  <chr>          <chr>     
#>  1 ank    Ankara         Turkey    
#>  2 bel    Belgium        NA        
#>  3 ber    Berlin         Germany   
#>  4 bre    Brest          France    
#>  5 bud    Budapest       Austria   
#>  6 bul    Bulgaria       NA        
#>  7 con    Constantinople Turkey    
#>  8 den    Denmark        NA        
#>  9 edi    Edinburgh      England   
#> 10 gre    Greece         NA        
#> # ℹ 24 more rows
dp_supply_centres(dp_new_game())
#> # A tibble: 34 × 5
#>    centre name           home_power owner   occupied_by
#>    <chr>  <chr>          <chr>      <chr>   <chr>      
#>  1 ank    Ankara         Turkey     Turkey  Turkey     
#>  2 bel    Belgium        NA         NA      NA         
#>  3 ber    Berlin         Germany    Germany Germany    
#>  4 bre    Brest          France     France  France     
#>  5 bud    Budapest       Austria    Austria Austria    
#>  6 bul    Bulgaria       NA         NA      NA         
#>  7 con    Constantinople Turkey     Turkey  Turkey     
#>  8 den    Denmark        NA         NA      NA         
#>  9 edi    Edinburgh      England    England England    
#> 10 gre    Greece         NA         NA      NA         
#> # ℹ 24 more rows
```
