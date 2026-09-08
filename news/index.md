# Changelog

## diplomacyR 0.1.0

- First release.
- [`dp_map()`](https://r-heller.github.io/diplomacyR/reference/dp_map.md)
  loads the standard seven-power board: 75 provinces, per-coast fleet
  adjacency, 34 supply centres and the canonical opening position.
- [`dp_adjudicate()`](https://r-heller.github.io/diplomacyR/reference/dp_adjudicate.md)
  resolves movement phases under the standard rules, including support
  cutting, convoy paths, convoy paradoxes, standoffs and the
  self-dislodgement prohibitions. The engine passes every movement-phase
  case of the Diplomacy Adjudicator Test Cases (DATC section 6.A-6.G).
- [`dp_retreat()`](https://r-heller.github.io/diplomacyR/reference/dp_retreat.md),
  [`dp_build()`](https://r-heller.github.io/diplomacyR/reference/dp_build.md)
  and
  [`dp_advance()`](https://r-heller.github.io/diplomacyR/reference/dp_advance.md)
  complete the phase machine;
  [`dp_step()`](https://r-heller.github.io/diplomacyR/reference/dp_step.md)
  and
  [`dp_play()`](https://r-heller.github.io/diplomacyR/reference/dp_play.md)
  drive whole games.
- Bots
  ([`dp_ai_orders()`](https://r-heller.github.io/diplomacyR/reference/dp_ai_orders.md)),
  batch simulation
  ([`dp_simulate()`](https://r-heller.github.io/diplomacyR/reference/dp_simulate.md))
  and analysis
  ([`dp_stats()`](https://r-heller.github.io/diplomacyR/reference/dp_stats.md),
  [`dp_power_summary()`](https://r-heller.github.io/diplomacyR/reference/dp_power_summary.md)).
- `ggplot2` renderers for the board, supply-centre histories and
  simulation dashboards.
- A `shiny` application,
  [`dp_run_app()`](https://r-heller.github.io/diplomacyR/reference/dp_run_app.md),
  for interactive play.
