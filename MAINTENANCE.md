# Maintenance review — 30 October 2026

## Purpose and acceptance criteria

A standard-map Diplomacy engine with simultaneous adjudication, bots, batch
analysis and an interactive app. This increment preserves supported game rules,
requires reproducible seeded simulation without changing surrounding analyses,
rejects invalid counts before coercion, and verifies the installed first turn.

## Findings and completed work

- High, `R/engine.R` and `R/simulate.R`: the private seed helper claimed to avoid
  leaking RNG state but only called `set.seed()`. Both entry points now preserve
  and restore the previous random state, including absence and error exits.
- Medium, `R/utils.R`: count validation coerced infinity/overflow before checking,
  producing warnings and missing logical conditions. Check finite whole values
  within the integer range first. Seeds use the same validated path.
- Medium: year/loop-cap arithmetic could overflow before play. The year limit
  is explicit and loop-cap arithmetic uses double precision.
- Packaging: exclude linked-worktree `.git` metadata from source archives.

## Validation

On macOS arm64 with R 4.6.1, full source tests passed (109.87 s), including the
existing 130 encoded DATC movement cases and added RNG/count regressions. Final
source build with vignettes passed (45.76 s); full `R CMD check --no-manual`
passed (107.32 s), Status OK. The installed package resolved the README's
supported France-to-Burgundy attack, advanced to Fall 1901, and played a seeded
bot game without changing the surrounding RNG state.

Chromium checked the installed app outside the checkout: board rendering,
resolve-and-advance, the resulting order table, history and analysis tabs.
No browser or Shiny output errors occurred. This does not independently certify
unencoded rules or all possible simultaneous-order interactions.

## First use and remaining work

Use the README installation, `dp_new_game()` and its first-turn example, or
`dp_run_app()`. The repair criteria are satisfied locally. Future enhancements
are additional independent adjudicator comparisons and meaningful browser CI;
no extra rules or bots were added. Review/integrate the candidate branch and run
remote CI before release. No push, CRAN submission or app deployment occurred.
