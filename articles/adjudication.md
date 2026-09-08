# How the adjudicator resolves a turn

``` r

library(diplomacyR)
```

Every unit in Diplomacy has exactly the same strength, and every order
is written in secret and revealed at the same moment. A unit moves into
a province only if it pushes harder than everything opposing it; the
only way to push harder is to be supported; and the only way to take
support away is to attack the supporting unit. Those three sentences
generate the entire rulebook, and also all of its famous edge cases,
because the outcome of one order routinely depends on the outcome of
another that depends back on the first.

This vignette walks through the cases the engine has to get right, one
worked position at a time. Each position is built with
[`dp_game_from_units()`](https://r-heller.github.io/diplomacyR/reference/dp_game_from_units.md)
and resolved with
[`dp_adjudicate()`](https://r-heller.github.io/diplomacyR/reference/dp_adjudicate.md).
To keep the code short, here is a small helper that takes units written
as `"Power type province"` and a set of orders, and returns the resolved
`dp_result`:

``` r

resolve <- function(units, orders) {
  spec <- do.call(rbind, strsplit(units, " ", fixed = TRUE))
  game <- dp_game_from_units(data.frame(
    power = spec[, 1], type = spec[, 2], loc = spec[, 3]
  ))
  dp_adjudicate(game, orders)
}
```

Printing the `orders` element of a result marks each order with a tick
or a cross, which is the quickest way to read a position.

## Support and dislodgement

An unsupported attack on an occupied province achieves nothing: one
against one is a tie, and ties bounce. Add a single support and the
attack becomes two against one.

``` r

res <- resolve(
  c("France army bur", "France army ruh", "Germany army mun"),
  c("France: A Bur - Mun",
    "France: A Ruh S A Bur - Mun",
    "Germany: A Mun H")
)
res$orders
#> <dp_orders> (3 orders)
#> ✔ France: A Bur - Mun
#> ✔ France: A Ruh S A Bur - Mun
#> ✔ Germany: A Mun H
```

All three orders are marked successful, including Germany’s hold. A tick
means the order was carried out as written, not that the unit came out
well: Munich held, and was dislodged anyway.

``` r

res$dislodged
#> # A tibble: 1 × 5
#>   power   type  loc   from  by_convoy
#>   <chr>   <chr> <chr> <chr> <lgl>    
#> 1 Germany army  mun   bur   FALSE
```

The `from` column records where the attack came from, and the dislodged
unit is barred from retreating back into it. `by_convoy` matters for the
same reason: an army dislodged by a convoyed attack *may* retreat into
the attacker’s province, because the attacker never travelled through
it.

## Standoffs

Two attacks of equal strength on an empty province cancel and nobody
moves.

``` r

res <- resolve(
  c("France army bur", "Germany army ruh"),
  c("France: A Bur - Mun", "Germany: A Ruh - Mun")
)
res$orders
#> <dp_orders> (2 orders)
#> ✖ France: A Bur - Mun
#> ✖ Germany: A Ruh - Mun
res$contested
#> [1] "mun"
```

Munich is left contested. That is not just bookkeeping: a province where
a standoff occurred is closed to retreats for the rest of the turn, so a
unit dislodged elsewhere cannot slip into it.

Units belonging to the same power stand each other off in exactly the
same way. There is no rule that lets a power sort out its own traffic.

``` r

res <- resolve(
  c("Germany army ber", "Germany army sil"),
  c("Germany: A Ber - Pru", "Germany: A Sil - Pru")
)
res$orders
#> <dp_orders> (2 orders)
#> ✖ Germany: A Ber - Pru
#> ✖ Germany: A Sil - Pru
```

## Cutting support

A support order is cut by any attack on the supporting unit from a power
other than its own, whether or not the attack succeeds. Here Germany
never gets into the Ruhr, but the attempt is enough to take France’s
support away, and the French attack on Munich collapses to one against
one.

``` r

res <- resolve(
  c("France army bur", "France army ruh",
    "Germany army mun", "Germany army kie"),
  c("France: A Bur - Mun",
    "France: A Ruh S A Bur - Mun",
    "Germany: A Mun H",
    "Germany: A Kie - Ruh")
)
res$orders
#> <dp_orders> (4 orders)
#> ✖ France: A Bur - Mun
#> ✖ France: A Ruh S A Bur - Mun
#> ✔ Germany: A Mun H
#> ✖ Germany: A Kie - Ruh
```

There is one exception, and it is the exception that makes supported
attacks worth ordering at all. An attack coming *out of* the province
the support is directed into does not cut that support. Otherwise every
supported attack could be neutralised by the defender simply attacking
back.

``` r

res <- resolve(
  c("Austria army tri", "Austria army tyr", "Italy army ven"),
  c("Austria: A Tri S A Tyr - Ven",
    "Austria: A Tyr - Ven",
    "Italy: A Ven - Tri")
)
res$orders
#> <dp_orders> (3 orders)
#> ✔ Austria: A Tri S A Tyr - Ven
#> ✔ Austria: A Tyr - Ven
#> ✖ Italy: A Ven - Tri
res$dislodged
#> # A tibble: 1 × 5
#>   power type  loc   from  by_convoy
#>   <chr> <chr> <chr> <chr> <lgl>    
#> 1 Italy army  ven   tyr   FALSE
```

Venice attacks Trieste, which is the very province supporting the attack
on Venice. The support stands, Tyrolia moves in with strength two, and
the Italian army is dislodged. Such an attack cuts support only by
actually dislodging the supporting unit.

## No self-dislodgement

A power may never dislodge its own unit, however much support it brings,
and support belonging to the attacked unit’s own power is discounted
from the attack. Here Germany attacks Germany with two against one and
still fails.

``` r

res <- resolve(
  c("Germany army bur", "Germany army ruh", "Germany army mun"),
  c("Germany: A Bur - Mun",
    "Germany: A Ruh S A Bur - Mun",
    "Germany: A Mun H")
)
res$orders
#> <dp_orders> (3 orders)
#> ✖ Germany: A Bur - Mun
#> ✔ Germany: A Ruh S A Bur - Mun
#> ✔ Germany: A Mun H
```

The support is marked successful — it was given — but it buys nothing,
because the move it backs is against a unit of its own power.

## The beleaguered garrison

The same rule that produces standoffs also protects a unit that
everybody is attacking at once. Denmark is attacked from two sides with
strength two each. Neither attack is stronger than the other, so both
bounce, and the German fleet sitting in Denmark survives without lifting
a finger.

``` r

res <- resolve(
  c("England fleet nth", "England fleet hel",
    "Russia fleet swe", "Russia fleet bal",
    "Germany fleet den"),
  c("England: F Nth - Den", "England: F Hel S F Nth - Den",
    "Russia: F Swe - Den", "Russia: F Bal S F Swe - Den",
    "Germany: F Den H")
)
res$orders
#> <dp_orders> (5 orders)
#> ✖ England: F Nth - Den
#> ✔ England: F Hel S F Nth - Den
#> ✖ Russia: F Swe - Den
#> ✔ Russia: F Bal S F Swe - Den
#> ✔ Germany: F Den H
res$dislodged
#> # A tibble: 0 × 5
#> # ℹ 5 variables: power <chr>, type <chr>, loc <chr>, from <chr>,
#> #   by_convoy <lgl>
```

## Convoys

An army can cross water if a chain of fleets, each explicitly ordered to
convoy that exact move, links its province to the destination.

``` r

res <- resolve(
  c("England army lon", "England fleet nth"),
  c("England: A Lon - Bel", "England: F Nth C A Lon - Bel")
)
res$orders
#> <dp_orders> (2 orders)
#> ✔ England: A Lon - Bel
#> ✔ England: F Nth C A Lon - Bel
res$units
#> # A tibble: 2 × 3
#>   power   type  loc  
#>   <chr>   <chr> <chr>
#> 1 England army  bel  
#> 2 England fleet nth
```

The chain only holds while every fleet on it holds. Dislodge one and the
army never leaves home.

``` r

res <- resolve(
  c("England army lon", "England fleet nth",
    "Germany fleet hel", "Germany fleet ska"),
  c("England: A Lon - Bel", "England: F Nth C A Lon - Bel",
    "Germany: F Hel - Nth", "Germany: F Ska S F Hel - Nth")
)
res$orders
#> <dp_orders> (4 orders)
#> ✖ England: A Lon - Bel
#> ✖ England: F Nth C A Lon - Bel
#> ✔ Germany: F Hel - Nth
#> ✔ Germany: F Ska S F Hel - Nth
```

Where a land route and a sea route both exist, intent decides. An army
ordered to an adjacent province goes overland unless the order says
`via Convoy`, or unless one of its own power’s fleets is sitting on a
plausible route and has ordered the convoy. A foreign fleet cannot
commandeer someone else’s army by ordering a convoy it did not ask for.

## The convoy paradox

Now the case that makes naive adjudicators loop forever. England orders
a fleet from Wales into the English Channel, supported from London.
France orders the fleet in the Channel to convoy an army from Brest to
London.

The paradox: if the French convoy goes through, the army arrives in
London and cuts the support for the English attack, so the attack fails,
so the Channel fleet is not dislodged, so the convoy goes through. If
the convoy fails, London’s support stands, the Channel fleet is
dislodged, so the convoy fails. Both readings are self-consistent, and
the rulebook does not choose between them.

``` r

res <- resolve(
  c("England fleet lon", "England fleet wal",
    "France army bre", "France fleet eng"),
  c("England: F Lon S F Wal - Eng",
    "England: F Wal - Eng",
    "France: A Bre - Lon",
    "France: F Eng C A Bre - Lon")
)
res$orders
#> <dp_orders> (4 orders)
#> ✔ England: F Lon S F Wal - Eng
#> ✔ England: F Wal - Eng
#> ✖ France: A Bre - Lon
#> ✖ France: F Eng C A Bre - Lon
res$dislodged
#> # A tibble: 1 × 5
#>   power  type  loc   from  by_convoy
#>   <chr>  <chr> <chr> <chr> <lgl>    
#> 1 France fleet eng   wal   FALSE
```

The engine detects that the orders form a cycle and applies the Szykman
rule: a cycle involving a convoy is broken by disrupting the convoy. The
convoy fails, the army stays in Brest, and the Channel fleet is
dislodged. This is the outcome the Diplomacy Adjudicator Test Cases
prescribe as preferred.

Cycles that do not involve a convoy are broken the other way. A ring of
units each moving into the province the next one is leaving is not a
paradox at all — it just needs the engine to notice that resolving any
one of the moves requires resolving all of them.

``` r

res <- resolve(
  c("Turkey fleet ank", "Turkey army con", "Turkey army smy"),
  c("Turkey: F Ank - Con", "Turkey: A Con - Smy", "Turkey: A Smy - Ank")
)
res$orders
#> <dp_orders> (3 orders)
#> ✔ Turkey: F Ank - Con
#> ✔ Turkey: A Con - Smy
#> ✔ Turkey: A Smy - Ank
res$units
#> # A tibble: 3 × 3
#>   power  type  loc  
#>   <chr>  <chr> <chr>
#> 1 Turkey fleet con  
#> 2 Turkey army  smy  
#> 3 Turkey army  ank
```

Every unit moves, and nothing is dislodged.

## Illegal orders

An order that the rules forbid is never rejected outright, because a
unit always has to be doing something. It is converted into a hold and
the reason is recorded in the `note` column.

``` r

res <- resolve(
  c("France army par", "France fleet bre"),
  c("France: A Par - Mun", "France: F Bre S A Par - Mun")
)
summary(res)[, c("power", "loc", "type", "target", "note")]
#> # A tibble: 2 × 5
#>   power  loc   type  target note                                       
#>   <chr>  <chr> <chr> <chr>  <chr>                                      
#> 1 France par   hold  NA     illegal move (holds)                       
#> 2 France bre   hold  NA     cannot reach the supported province (holds)
```

Paris does not border Munich and no convoy could carry an army there, so
the move is void; Brest cannot reach Munich either, so the support is
void as well. Both units hold.

## Conformance

The engine is validated against the Diplomacy Adjudicator Test Cases,
the reference suite assembled by Lucas B. Kruijswijk. It passes all 130
movement-phase cases, covering sections 6.A to 6.G: basic legality,
coasts, circular movement, supports and dislodges, head-to-head battles,
convoys and convoy paradoxes, and the rules on convoying to one’s own
area. The encoded cases ship with the package under `extdata/datc`.

``` r

datc <- system.file("extdata", "datc", package = "diplomacyR")
list.files(datc)
#> [1] "datc_6a_6g.json" "datc_6h_6j.json"
```

Where the test cases allow more than one defensible answer — the convoy
paradoxes above are the main example — the engine implements the option
the suite marks as preferred.
