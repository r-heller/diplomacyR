# Draw the board

Renders the board as a map. Every province is drawn as a territory
rather than a point: seas in blue, coastal land and inland in two shades
of buff, with coastlines picked out against the province borders. A
supply centre wears its name on a chip coloured for the power that holds
it, so the balance of the game is visible at a glance. Units are tokens
in their power's colour – a circle for an army, a diamond for a fleet –
and units awaiting a retreat are ringed in red.

## Usage

``` r
dp_plot_map(
  game,
  orders = NULL,
  labels = TRUE,
  ownership = TRUE,
  title = NULL,
  subtitle = NULL
)
```

## Arguments

- game:

  A
  [dp_game](https://r-heller.github.io/diplomacyR/reference/dp_game.md)
  object.

- orders:

  Optional orders to draw over the board, as a `dp_orders` tibble.
  `TRUE` draws the orders the game last resolved, if it has any.

- labels:

  Draw the three-letter province codes. Default `TRUE`.

- ownership:

  Colour each supply centre's chip for the power that holds it. Default
  `TRUE`; `FALSE` leaves every chip neutral.

- title:

  Plot title. `NULL` uses the current turn.

- subtitle:

  Plot subtitle. `NULL` summarises the position.

## Value

A ggplot2 object.

## Details

Terrain and ownership are deliberately encoded in different ways.
Terrain gets the large quiet fills and ownership the small saturated
chips, because washing a power's colour across a whole province makes a
blue power's land look like sea.

Pass `orders` to draw the turn on the board: solid arrows for moves and
retreats, dashed for supports, dash-dotted for convoys. If the orders
have been adjudicated, and so carry a `success` column, the arrows that
failed are marked with a cross at their head.

The board is schematic. Provinces sit at fixed coordinates and their
shapes come from tessellating the plane between them, so the outlines
are suggestive of Europe rather than a faithful coastline.

The board is close to square. Give it a close-to-square figure: the
default `7 x 5` of many rendering setups leaves a third of the width
empty and squeezes the province names together.

## See also

Other plot:
[`autoplot.dp_game()`](https://r-heller.github.io/diplomacyR/reference/autoplot.dp_game.md),
[`dp_palette()`](https://r-heller.github.io/diplomacyR/reference/dp_palette.md),
[`dp_plot_centres()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_centres.md),
[`dp_plot_sc_history()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_sc_history.md),
[`dp_plot_supply_heatmap()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_supply_heatmap.md),
[`dp_plot_winrates()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_winrates.md)

## Examples

``` r
dp_plot_map(dp_new_game())


g <- dp_new_game()
dp_plot_map(g, orders = dp_example_orders())
```
