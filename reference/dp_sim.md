# A batch of simulated games

A `dp_sim` collects the outcomes of many games played by bots.
[`dp_simulate()`](https://r-heller.github.io/diplomacyR/reference/dp_simulate.md)
returns one;
[`dp_stats()`](https://r-heller.github.io/diplomacyR/reference/dp_stats.md)
and the `dp_plot_*` functions summarise it.

## Details

- `games`:

  One row per game: `game`, `outcome`, `winner`, `years`, `turns`.

- `centres`:

  Final supply-centre and unit counts, one row per game and power.

- `contests`:

  How often a standoff occurred in each province.

- `settings`:

  The arguments the simulation was run with.

## See also

[`dp_simulate()`](https://r-heller.github.io/diplomacyR/reference/dp_simulate.md),
[`dp_stats()`](https://r-heller.github.io/diplomacyR/reference/dp_stats.md),
[`is_dp_sim()`](https://r-heller.github.io/diplomacyR/reference/is_dp_sim.md)

Other simulation:
[`dp_simulate()`](https://r-heller.github.io/diplomacyR/reference/dp_simulate.md),
[`dp_stats()`](https://r-heller.github.io/diplomacyR/reference/dp_stats.md),
[`is_dp_sim()`](https://r-heller.github.io/diplomacyR/reference/is_dp_sim.md)

## Examples

``` r
sim <- dp_simulate(n = 1, bots = "hold", max_years = 2, verbose = FALSE)
sim$games
#> # A tibble: 1 × 5
#>    game outcome winner years turns
#>   <int> <chr>   <chr>  <int> <int>
#> 1     1 draw    NA         3     6
```
