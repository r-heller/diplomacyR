# Order notation reference

``` r

library(diplomacyR)
```

Diplomacy players write orders in a compact shorthand that has been
stable for decades but was never standardised.
[`dp_parse_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_parse_orders.md)
accepts the spellings people actually use, and
[`format()`](https://rdrr.io/r/base/format.html) renders any `dp_orders`
tibble back into one canonical form. This vignette is the reference for
both.

Every example below is parsed and then rendered back, so the second
column is what the engine understood.

``` r

notation <- function(x, ...) {
  knitr::kable(data.frame(
    Written = x,
    Understood = format(dp_parse_orders(x, ...))
  ))
}
```

## The shape of an order

An order is

    Power: <unit> <verb> <arguments>

The power prefix may be dropped if the `power` argument supplies it
instead. Everything is case-insensitive, and powers may be abbreviated
to any unambiguous prefix.

``` r

notation(c(
  "France: A Par - Bur",
  "FRANCE: A Par - Bur",
  "Fra: A Par - Bur",
  "F: A Par - Bur"
))
```

| Written             | Understood          |
|:--------------------|:--------------------|
| France: A Par - Bur | France: A Par - Bur |
| FRANCE: A Par - Bur | France: A Par - Bur |
| Fra: A Par - Bur    | France: A Par - Bur |
| F: A Par - Bur      | France: A Par - Bur |

``` r

dp_parse_orders(c("A Par - Bur", "A Mar - Spa"), power = "France")
#> <dp_orders> (2 orders)
#> France: A Par - Bur
#> France: A Mar - Spa
```

## Locations

Provinces are three-letter codes. Full province names are accepted too
and are translated to codes.

``` r

notation(c(
  "France: A Par - Bur",
  "France: A Paris - Burgundy",
  "France: A paris to burgundy"
))
```

| Written                     | Understood          |
|:----------------------------|:--------------------|
| France: A Par - Bur         | France: A Par - Bur |
| France: A Paris - Burgundy  | France: A Par - Bur |
| France: A paris to burgundy | France: A Par - Bur |

Three provinces on the standard board have two coasts that a fleet
cannot sail between: Spain (`nc`, `sc`), Bulgaria (`ec`, `sc`) and St
Petersburg (`nc`, `sc`). Write the coast after a slash, or in brackets.

``` r

notation(c(
  "Russia: F Stp/sc - Bot",
  "Russia: F Stp (sc) - Bot",
  "Russia: F STP/SC - BOT",
  "Turkey: F Bul/ec - Bla"
))
```

| Written                  | Understood             |
|:-------------------------|:-----------------------|
| Russia: F Stp/sc - Bot   | Russia: F Stp/sc - Bot |
| Russia: F Stp (sc) - Bot | Russia: F Stp/sc - Bot |
| Russia: F STP/SC - BOT   | Russia: F Stp/sc - Bot |
| Turkey: F Bul/ec - Bla   | Turkey: F Bul/ec - Bla |

A coast is only required where the choice is genuinely ambiguous. If
exactly one coast of the destination is reachable, the engine fills it
in for you when it adjudicates; if two are, the order is void and the
unit holds.

## Units

`A` and `F` mark armies and fleets, and the long forms `army` and
`fleet` work as well. The designator is optional — the engine reads the
real unit type off the board — but including it is the convention, and
it makes an order set readable on its own.

``` r

notation(c(
  "France: A Par - Bur",
  "France: army Par - Bur",
  "France: Par - Bur"
))
```

| Written                | Understood          |
|:-----------------------|:--------------------|
| France: A Par - Bur    | France: A Par - Bur |
| France: army Par - Bur | France: A Par - Bur |
| France: Par - Bur      | France: Par - Bur   |

## Holds

A unit with no verb holds. `H`, `hold`, `holds`, `stand` and `stands`
all say the same thing explicitly.

``` r

notation(c(
  "Austria: A Bud H",
  "Austria: A Bud holds",
  "Austria: A Bud stands",
  "Austria: A Bud"
))
```

| Written               | Understood       |
|:----------------------|:-----------------|
| Austria: A Bud H      | Austria: A Bud H |
| Austria: A Bud holds  | Austria: A Bud H |
| Austria: A Bud stands | Austria: A Bud H |
| Austria: A Bud        | Austria: A Bud H |

## Moves

The move arrow may be a hyphen, an arrow, a dash of any Unicode flavour,
or the word `to`. Spaces around it are optional.

``` r

notation(c(
  "France: A Par - Bur",
  "France: A Par-Bur",
  "France: A Par -> Bur",
  "France: A Par to Bur"
))
```

| Written               | Understood          |
|:----------------------|:--------------------|
| France: A Par - Bur   | France: A Par - Bur |
| France: A Par-Bur     | France: A Par - Bur |
| France: A Par -\> Bur | France: A Par - Bur |
| France: A Par to Bur  | France: A Par - Bur |

## Supports

A support either backs a unit that is staying where it is, in which case
only the supported unit’s province is named, or backs a move, in which
case the whole move is written out. `S`, `sup`, `supp`, `support` and
`supports` are interchangeable, and the supported unit’s own designator
is optional.

``` r

notation(c(
  "England: F Lon S F Yor",
  "England: F Lon S Yor",
  "England: F Lon S A Wal - Yor",
  "England: F Lon supports A Wal - Yor"
))
```

| Written                             | Understood                   |
|:------------------------------------|:-----------------------------|
| England: F Lon S F Yor              | England: F Lon S F Yor       |
| England: F Lon S Yor                | England: F Lon S Yor         |
| England: F Lon S A Wal - Yor        | England: F Lon S A Wal - Yor |
| England: F Lon supports A Wal - Yor | England: F Lon S A Wal - Yor |

## Convoys

A convoy order names the army and its full move. `C`, `conv`, `convoy`
and `convoys` are interchangeable.

``` r

notation(c(
  "England: F Nth C A Lon - Nwy",
  "England: F Nth convoys A Lon - Nwy",
  "England: F Nth C Lon - Nwy"
))
```

| Written                            | Understood                   |
|:-----------------------------------|:-----------------------------|
| England: F Nth C A Lon - Nwy       | England: F Nth C A Lon - Nwy |
| England: F Nth convoys A Lon - Nwy | England: F Nth C A Lon - Nwy |
| England: F Nth C Lon - Nwy         | England: F Nth C Lon - Nwy   |

The army being convoyed is ordered to move as usual. Where the
destination is not adjacent, the move is a convoy automatically. Where
both a land route and a sea route exist, append `via convoy` — or
`by convoy` — to insist on the sea route.

``` r

notation(c(
  "England: A Lon - Bel via convoy",
  "England: A Lon - Bel by convoy"
))
```

| Written                         | Understood                      |
|:--------------------------------|:--------------------------------|
| England: A Lon - Bel via convoy | England: A Lon - Bel via Convoy |
| England: A Lon - Bel by convoy  | England: A Lon - Bel via Convoy |

This is the one distinction
[`format()`](https://rdrr.io/r/base/format.html) preserves in the
rendered output, as `via Convoy`, because it changes the meaning of the
order.

## Retreat phases

The `phase` argument tells the parser which kind of turn the orders
belong to. In a retreat phase a bare move arrow means a retreat; `R`,
`retreat` and `retreats` say so explicitly and work in any phase. A
dislodged unit that is not retreating is removed with `D`, `disband` or
`remove`.

``` r

notation(
  c("Austria: A Tri R Alb",
    "Austria: A Tri retreats Alb",
    "Austria: A Tri - Alb",
    "Austria: A Tri D"),
  phase = "retreat"
)
```

| Written                     | Understood            |
|:----------------------------|:----------------------|
| Austria: A Tri R Alb        | Austria: A Tri R Alb  |
| Austria: A Tri retreats Alb | Austria: A Tri R Alb  |
| Austria: A Tri - Alb        | Austria: A Tri R Alb  |
| Austria: A Tri D            | Austria: Remove A Tri |

## Adjustment phases

Winter orders build and remove units. Builds must name the unit type,
since there is no unit on the board to read it from; removals need not.

``` r

notation(
  c("Germany: Build A Ber",
    "Germany: Build F Kie",
    "Germany: F Kie B",
    "Germany: Remove F Ber",
    "Germany: Disband A Mun",
    "Germany: A Mun",
    "Germany: Waive"),
  phase = "build"
)
```

| Written                | Understood            |
|:-----------------------|:----------------------|
| Germany: Build A Ber   | Germany: Build A Ber  |
| Germany: Build F Kie   | Germany: Build F Kie  |
| Germany: F Kie B       | Germany: Build F Kie  |
| Germany: Remove F Ber  | Germany: Remove F Ber |
| Germany: Disband A Mun | Germany: Remove A Mun |
| Germany: A Mun         | Germany: Remove A Mun |
| Germany: Waive         | Germany: Waive        |

Note the last two rows. In an adjustment phase a bare `A Mun` is a
removal, not a hold — there is nothing to hold in a winter turn. `Waive`
declines a build that is owed, which matters when a power would rather
not put a unit on the board.

A fleet built on a split-coast province names its coast the same way a
move does.

``` r

notation("Russia: Build F Stp/sc", phase = "build")
```

| Written                | Understood             |
|:-----------------------|:-----------------------|
| Russia: Build F Stp/sc | Russia: Build F Stp/sc |

## Writing several orders at once

[`dp_parse_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_parse_orders.md)
takes a character vector of orders, but it also splits on newlines and
semicolons, so a whole turn can be pasted in as one string. Anything
after a `#` is a comment.

``` r

dp_parse_orders(
  "A Par - Bur      # open towards Munich
   A Mar S A Par - Bur
   F Bre - Mao",
  power = "France"
)
#> <dp_orders> (3 orders)
#> France: A Par - Bur
#> France: A Mar S A Par - Bur
#> France: F Bre - Mao
```

## Round trips

[`format()`](https://rdrr.io/r/base/format.html) renders orders in one
canonical spelling: power prefix, unit designator, three-letter codes
with the first letter capitalised, and the single-letter verbs. Parsing
the rendered text gives the same orders back.

``` r

orders <- dp_example_orders("fall_1901")
canonical <- format(orders)
head(canonical, 4)
#> [1] "Austria: A Tri H"             "Austria: A Ser - Gre"        
#> [3] "Austria: F Alb S A Ser - Gre" "England: F Nth - Nwy"
```

``` r

identical(format(dp_parse_orders(canonical)), canonical)
#> [1] TRUE
```

[`as.character()`](https://rdrr.io/r/base/character.html) on a
`dp_orders` tibble is the same as
[`format()`](https://rdrr.io/r/base/format.html), and
[`as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
strips the class to expose the columns the engine actually works with.

``` r

as_tibble(dp_parse_orders("England: F Nth C A Lon - Nwy"))
#> # A tibble: 1 × 9
#>   power   type   unit_type loc   target aux_type aux_loc aux_target via_convoy
#>   <chr>   <chr>  <chr>     <chr> <chr>  <chr>    <chr>   <chr>      <lgl>     
#> 1 England convoy fleet     nth   NA     army     lon     nwy        FALSE
```

## When an order cannot be read

A string that is not an order at all is an error, with the offending
piece named. This is deliberate: a typo in an order set should stop the
turn rather than quietly become a hold.

``` r

dp_parse_orders("France: A Par flies to Bur")
#> Error:
#> ! Could not parse the order "A Par flies to Bur".
#> ✖ "flies to bur" is not a recognised order verb.
#> ℹ Use "-" (move), "H", "S", "C", "R", "Build" or "Remove".
```

``` r

dp_parse_orders("France: A Xyz - Bur")
#> Error:
#> ! Could not parse the order "A Xyz - Bur".
#> ✖ Unit location "xyz" is not a province on this board.
```

``` r

dp_parse_orders("A Par - Bur")
#> Error:
#> ! No power given for order "A Par - Bur".
#> ℹ Prefix the order with `Power:` or set `power`.
```

An order that parses but breaks the rules of the board is a different
matter. Those are accepted here and dealt with by the adjudicator, which
converts them to holds and records why — see
[`vignette("adjudication")`](https://r-heller.github.io/diplomacyR/articles/adjudication.md).
