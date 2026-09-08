# Simulate many Diplomacy games

Plays `n` games to completion – a solo victory, an elimination of all
but one power, or the turn cap and a draw – with the given bot
assignment, and collects the outcomes.

## Usage

``` r
dp_simulate(
  n = 100,
  bots = "greedy",
  max_years = 20,
  seed = NULL,
  verbose = TRUE,
  call = rlang::caller_env()
)
```

## Arguments

- n:

  Number of games.

- bots:

  A single bot name applied to all powers, or a named character vector
  mapping power to bot. See
  [`dp_ai_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_ai_orders.md).

- max_years:

  Turn cap before the game is declared a draw. Default `20`.

- seed:

  Optional RNG seed for reproducibility.

- verbose:

  Report progress. Default `TRUE`.

- call:

  Caller environment, for error reporting. Experts only.

## Value

A [dp_sim](https://r-heller.github.io/diplomacyR/reference/dp_sim.md)
object. Summarise it with
[`dp_stats()`](https://r-heller.github.io/diplomacyR/reference/dp_stats.md)
and the `dp_plot_*` functions.

## See also

Other simulation:
[`dp_sim`](https://r-heller.github.io/diplomacyR/reference/dp_sim.md),
[`dp_stats()`](https://r-heller.github.io/diplomacyR/reference/dp_stats.md),
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
```
