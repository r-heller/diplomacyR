# diplomacyR 0.1.0

* First release.
* `dp_map()` loads the standard seven-power board: 75 provinces, per-coast
  fleet adjacency, 34 supply centres and the canonical opening position.
* `dp_adjudicate()` resolves movement phases under the standard rules,
  including support cutting, convoy paths, convoy paradoxes, standoffs and the
  self-dislodgement prohibitions. The engine passes every movement-phase case
  of the Diplomacy Adjudicator Test Cases (DATC section 6.A-6.G).
* `dp_retreat()`, `dp_build()` and `dp_advance()` complete the phase machine;
  `dp_step()` and `dp_play()` drive whole games.
* Bots (`dp_ai_orders()`), batch simulation (`dp_simulate()`) and analysis
  (`dp_stats()`, `dp_power_summary()`).
* `ggplot2` renderers for the board, supply-centre histories and simulation
  dashboards.
* A `shiny` application, `dp_run_app()`, for interactive play.
