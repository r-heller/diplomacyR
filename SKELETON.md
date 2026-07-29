# diplomacyR — Package Skeleton

```
diplomacyR/
├── DESCRIPTION
├── NAMESPACE                      # roxygen2-generated, never hand-edit
├── LICENSE                        # MIT
├── LICENSE.md
├── NEWS.md
├── README.Rmd
├── cran-comments.md
├── _pkgdown.yml
├── _build.R                       # canonical build script
├── .Rbuildignore
├── .gitignore
├── diplomacyR.svg                 # hex sticker (repo root)
│
├── R/
│   ├── diplomacyR-package.R       # "_PACKAGE" sentinel + rlang/.data imports
│   ├── map.R                      # dp_map(), standard map data loader, adjacency
│   ├── map-standard.R             # the 75-province standard board definition
│   ├── game.R                     # dp_new_game(), dp_game S3 constructor/validator/helper
│   ├── unit.R                     # dp_unit(), army/fleet constructors, coastal handling
│   ├── order.R                    # dp_order() parser: hold/move/support/convoy/retreat/build
│   ├── order-parse.R              # text-notation parser ("A Par - Bur", "F Lon S A Wal - Yor")
│   ├── adjudicate.R               # dp_adjudicate() — THE ENGINE (movement phase)
│   ├── adjudicate-support.R       # support counting, support-cut logic
│   ├── adjudicate-convoy.R        # convoy path resolution, convoy disruption/paradox
│   ├── adjudicate-dislodge.R      # dislodgement, standoffs, self-dislodgement rules
│   ├── retreat.R                  # dp_retreat() — retreat phase adjudication
│   ├── build.R                    # dp_build() — winter build/disband, home SC rules
│   ├── phase.R                    # dp_advance(): phase/season/year state machine
│   ├── scobench.R                 # supply-centre counting, ownership transfer, victory check
│   ├── engine.R                   # dp_step(), dp_play() high-level loop drivers
│   ├── ai.R                       # dp_ai_orders(): bot order generation (dispatch)
│   ├── ai-random.R                # legal-random baseline bot
│   ├── ai-holdbot.R               # hold-everything baseline
│   ├── ai-greedy.R                # greedy SC-grab heuristic bot
│   ├── ai-negotiator.R            # alliance-modelling heuristic bot (stretch)
│   ├── simulate.R                 # dp_simulate(): batch many games, collect stats
│   ├── analyse.R                  # dp_stats(), power win-rates, SC trajectories, draws
│   ├── history.R                  # dp_history S3: turn-by-turn game record
│   ├── plot-map.R                 # dp_plot_map(): ggplot2 board renderer
│   ├── plot-sc.R                  # dp_plot_sc_history(): SC-count-over-time ggplot
│   ├── plot-analysis.R            # dp_plot_winrates(), dp_plot_supply_heatmap()
│   ├── print.R                    # print/format/summary S3 methods
│   ├── example-data.R             # dp_example_game(), dp_example_orders()
│   ├── run-app.R                  # dp_run_app() Shiny launcher
│   ├── utils.R                    # internal helpers (.check_* validators, %||%)
│   └── globals.R                  # utils::globalVariables() last-resort bindings
│
├── man/                           # roxygen2-generated
│   └── figures/
│       ├── logo.png
│       └── logo.svg
│
├── tests/
│   ├── testthat.R
│   └── testthat/
│       ├── helper-datc.R          # DATC case loader + harness
│       ├── test-map.R             # adjacency symmetry, coast correctness, 75 provinces
│       ├── test-order-parse.R     # notation round-trips, malformed input
│       ├── test-adjudicate-basic.R    # hold/move/bounce fundamentals
│       ├── test-adjudicate-support.R  # support given/cut/self-dislodge
│       ├── test-adjudicate-convoy.R   # convoys, convoy paradox, disruption
│       ├── test-datc.R            # THE big one: DATC 6.A–6.G compliance
│       ├── test-retreat.R
│       ├── test-build.R
│       ├── test-phase.R           # full-year state-machine progression
│       ├── test-victory.R         # 18-SC solo, draw conditions
│       ├── test-ai.R              # bots emit only legal orders
│       ├── test-simulate.R        # batch runs, type-stable stats tibbles
│       ├── test-plot.R            # every plot fn returns ggplot object
│       └── test-print.R           # S3 methods don't error
│
├── inst/
│   ├── extdata/
│   │   ├── standard_map.json      # province graph, coasts, SCs, home centres
│   │   └── datc/                  # DATC test cases as structured JSON/YAML
│   │       └── datc_6a_6g.json
│   ├── CITATION
│   ├── WORDLIST
│   └── shiny/
│       └── diplomacyR/
│           ├── app.R              # namespace-qualified, no library() calls
│           ├── global.R           # requireNamespace checks
│           ├── modules/
│           │   ├── mod_board.R        # Tab 1 — interactive board + unit placement
│           │   ├── mod_orders.R       # Tab 2 — order entry (click or notation) per power
│           │   ├── mod_adjudicate.R   # Tab 3 — resolve turn, show results/dislodges
│           │   ├── mod_history.R      # Tab 4 — timeline scrubber, replay
│           │   ├── mod_analysis.R     # Tab 5 — SC charts, win-rate dashboards
│           │   ├── mod_simulate.R     # Tab 6 — batch-sim runner + AI matchup config
│           │   └── mod_help.R         # Tab 7 — rules reference, notation cheatsheet
│           └── www/
│               ├── custom.css     # purple accent #5E2C8E
│               └── logo.png
│
├── vignettes/
│   ├── diplomacyR.Rmd             # Getting started: play one game start to finish
│   ├── adjudication.Rmd           # How the engine resolves orders (with diagrams)
│   ├── notation.Rmd               # Order notation reference
│   ├── ai-and-simulation.Rmd      # Bots + batch simulation + analysis
│   └── design.Rmd                 # S3 architecture, why the engine is structured this way
│
├── data-raw/
│   └── standard_map.R             # builds inst/extdata/standard_map.json from source
│
└── .github/
    └── workflows/
        ├── R-CMD-check.yaml
        ├── test-coverage.yaml
        └── pkgdown.yaml
```

## Core S3 objects

| Class          | Constructor         | Holds |
|----------------|---------------------|-------|
| `dp_map`       | `new_dp_map()`      | province graph, adjacency (army/fleet/coast-specific), SCs, home centres |
| `dp_game`      | `new_dp_game()`     | map + unit positions + SC ownership + season/year/phase + power status |
| `dp_orders`    | `new_dp_orders()`   | tibble of parsed orders for one phase, one or all powers |
| `dp_result`    | `new_dp_result()`   | adjudication outcome: which orders succeeded, dislodgements, standoffs |
| `dp_history`   | `new_dp_history()`  | ordered list of (game-state, orders, result) per turn |
| `dp_sim`       | `new_dp_sim()`      | batch-simulation results: per-game outcomes + aggregate stats tibbles |

## Function surface (all `dp_` prefixed, snake_case, verb_noun)

**Setup:**    `dp_map()` · `dp_new_game()` · `dp_example_game()`
**Orders:**   `dp_order()` · `dp_parse_orders()` · `dp_legal_orders()`
**Engine:**   `dp_adjudicate()` · `dp_retreat()` · `dp_build()` · `dp_advance()` · `dp_step()` · `dp_play()`
**AI:**       `dp_ai_orders()` (dispatch on `bot =`)
**Sim:**      `dp_simulate()` · `dp_stats()`
**Analyse:**  `dp_supply_centres()` · `dp_victory_check()` · `dp_power_summary()`
**Plot:**     `dp_plot_map()` · `dp_plot_sc_history()` · `dp_plot_winrates()` · `dp_plot_supply_heatmap()` · `autoplot.dp_game()`
**Coerce:**   `as_tibble.dp_orders()` · `as_tibble.dp_history()` · `is_dp_game()` etc.
**App:**      `dp_run_app()`
