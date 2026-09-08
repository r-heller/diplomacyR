# Play a game to completion

Steps the game until a power controls 18 supply centres or the turn cap
is reached, recording every turn.

## Usage

``` r
dp_play(
  game = dp_new_game(),
  bots = "greedy",
  max_years = 20,
  seed = NULL,
  verbose = FALSE,
  call = rlang::caller_env()
)
```

## Arguments

- game:

  A
  [dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
  object to start from. Defaults to a new game.

- bots:

  Bot assignment: a single bot name or a named character vector mapping
  power to bot.

- max_years:

  Stop after this many game years. Default `20`.

- seed:

  Optional RNG seed, for reproducibility.

- verbose:

  Report each year as it is played. Default `FALSE`.

- call:

  Caller environment, for error reporting. Experts only.

## Value

A
[dp_history](https://r-heller.github.io/diplomacyR/reference/dp_history.md)
object. The final state is in its last turn, and the outcome is on the
history's `outcome` element.

## See also

Other engine:
[`dp_adjudicate()`](https://r-heller.github.io/diplomacyR/reference/dp_adjudicate.md),
[`dp_advance()`](https://r-heller.github.io/diplomacyR/reference/dp_advance.md),
[`dp_build()`](https://r-heller.github.io/diplomacyR/reference/dp_build.md),
[`dp_result`](https://r-heller.github.io/diplomacyR/reference/dp_result.md),
[`dp_retreat()`](https://r-heller.github.io/diplomacyR/reference/dp_retreat.md),
[`dp_step()`](https://r-heller.github.io/diplomacyR/reference/dp_step.md),
[`is_dp_result()`](https://r-heller.github.io/diplomacyR/reference/is_dp_result.md)

## Examples

``` r
h <- dp_play(bots = "hold", max_years = 2)
as_tibble(h)
#> # A tibble: 42 × 7
#>     turn season  year phase    power   centres units
#>    <int> <chr>  <int> <chr>    <chr>     <int> <int>
#>  1     1 Spring  1901 movement Russia        4     4
#>  2     1 Spring  1901 movement Austria       3     3
#>  3     1 Spring  1901 movement England       3     3
#>  4     1 Spring  1901 movement France        3     3
#>  5     1 Spring  1901 movement Germany       3     3
#>  6     1 Spring  1901 movement Italy         3     3
#>  7     1 Spring  1901 movement Turkey        3     3
#>  8     2 Fall    1901 movement Russia        4     4
#>  9     2 Fall    1901 movement Austria       3     3
#> 10     2 Fall    1901 movement England       3     3
#> # ℹ 32 more rows
```
