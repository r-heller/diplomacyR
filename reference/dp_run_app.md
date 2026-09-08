# Launch the diplomacyR application

Opens the bundled shiny application: an interactive board, an order
editor with live legality checking, a turn adjudicator, a replayable
history, analysis charts and a batch-simulation runner.

## Usage

``` r
dp_run_app(..., call = rlang::caller_env())
```

## Arguments

- ...:

  Passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html), for
  example `port` or `launch.browser`.

- call:

  Caller environment, for error reporting. Experts only.

## Value

Invisibly `NULL`. Called for the side effect of running the app.

## Examples

``` r
# \donttest{
if (interactive()) {
  dp_run_app()
}
# }
```
