# Summarise a batch of simulated games

Summarise a batch of simulated games

## Usage

``` r
dp_stats(sim, what = c("power", "outcome", "length"))
```

## Arguments

- sim:

  A [dp_sim](https://r-heller.github.io/diplomacyR/reference/dp_sim.md)
  object.

- what:

  Which table to return:

  - `"power"` – one row per power: games played, solo wins, win rate,
    survival rate and mean final centre count.

  - `"outcome"` – one row per outcome type with its share.

  - `"length"` – the distribution of game lengths in years.

## Value

A tibble with stable columns, empty when the simulation is empty.

## See also

Other simulation:
[`dp_sim`](https://r-heller.github.io/diplomacyR/reference/dp_sim.md),
[`dp_simulate()`](https://r-heller.github.io/diplomacyR/reference/dp_simulate.md),
[`is_dp_sim()`](https://r-heller.github.io/diplomacyR/reference/is_dp_sim.md)

## Examples

``` r
sim <- dp_simulate(n = 2, bots = "hold", max_years = 2, verbose = FALSE)
dp_stats(sim)
#> # A tibble: 7 × 7
#>   power   games solos win_rate survival_rate mean_centres max_centres
#>   <chr>   <int> <int>    <dbl>         <dbl>        <dbl>       <int>
#> 1 Russia      2     0        0             1            4           4
#> 2 Austria     2     0        0             1            3           3
#> 3 England     2     0        0             1            3           3
#> 4 France      2     0        0             1            3           3
#> 5 Germany     2     0        0             1            3           3
#> 6 Italy       2     0        0             1            3           3
#> 7 Turkey      2     0        0             1            3           3
dp_stats(sim, "outcome")
#> # A tibble: 1 × 3
#>   outcome games share
#>   <chr>   <int> <dbl>
#> 1 draw        2     1
```
