# Chart supply-centre counts over a game

One line per power against the game calendar, with the solo-victory mark
drawn and labelled. The final standing is written at the right-hand end
of each line so the powers can be told apart without reading a legend.

## Usage

``` r
dp_plot_sc_history(history, threshold = 18, labels = TRUE)
```

## Arguments

- history:

  A
  [dp_history](https://r-heller.github.io/diplomacyR/reference/dp_history.md)
  object.

- threshold:

  Draw a reference line at this centre count. `NULL` omits it. Default
  `18`, the solo-victory mark. The line is skipped, rather than
  stretching the axis over empty space, in a game where no power came
  close to it.

- labels:

  Write each power's name at the end of its line. Default `TRUE`.

## Value

A ggplot2 object.

## Details

Centre counts are small integers, so powers are level with each other
for much of a normal game. Exactly coincident lines would hide all but
the last power drawn, so each power's line is offset by a fraction of a
centre. The offsets are a fixed, tiny fraction of the axis and are noted
on the plot.

## See also

Other plot:
[`autoplot.dp_game()`](https://r-heller.github.io/diplomacyR/reference/autoplot.dp_game.md),
[`dp_palette()`](https://r-heller.github.io/diplomacyR/reference/dp_palette.md),
[`dp_plot_centres()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_centres.md),
[`dp_plot_map()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_map.md),
[`dp_plot_supply_heatmap()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_supply_heatmap.md),
[`dp_plot_winrates()`](https://r-heller.github.io/diplomacyR/reference/dp_plot_winrates.md)

## Examples

``` r
h <- dp_play(bots = "hold", max_years = 2)
dp_plot_sc_history(h)
```
