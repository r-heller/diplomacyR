# The phase machine ------------------------------------------------------------
#
# A Diplomacy year runs Spring movement, Spring retreats, Fall movement, Fall
# retreats, then Winter adjustments. Retreat phases are skipped when nothing
# was dislodged, and supply-centre ownership changes exactly once a year,
# after the Fall retreats.

#' Which phase follows this one?
#'
#' @param season Current season.
#' @param phase Current phase.
#' @param dislodged Whether any unit needs to retreat.
#' @param year Current year.
#' @return A list with the next `season`, `phase` and `year`.
#' @noRd
.next_phase <- function(season, phase, dislodged, year) {
  if (phase == "movement") {
    if (dislodged) return(list(season = season, phase = "retreat", year = year))
    if (season == "Spring") {
      return(list(season = "Fall", phase = "movement", year = year))
    }
    return(list(season = "Winter", phase = "build", year = year))
  }
  if (phase == "retreat") {
    if (season == "Spring") {
      return(list(season = "Fall", phase = "movement", year = year))
    }
    return(list(season = "Winter", phase = "build", year = year))
  }
  list(season = "Spring", phase = "movement", year = year + 1L)
}

#' Advance a game by applying an adjudication result
#'
#' Applies the outcome of a phase to the game state and steps the season,
#' phase and year machine. Supply-centre ownership is recalculated as the game
#' leaves the autumn, and a solo victory or elimination is recorded in the
#' game's status.
#'
#' @param game A [dp_game] object.
#' @param result A [dp_result] from [dp_adjudicate()], [dp_retreat()] or
#'   [dp_build()].
#' @param call Caller environment, for error reporting. Experts only.
#' @return The next [dp_game] state.
#' @export
#' @family engine
#' @examples
#' g <- dp_new_game()
#' res <- dp_adjudicate(g, dp_example_orders("spring_1901"))
#' dp_advance(g, res)
dp_advance <- function(game, result, call = rlang::caller_env()) {
  .check_game(game, call = call)
  .check_class(result, "dp_result", call = call)

  game$units <- result$units
  game$dislodged <- result$dislodged
  game$contested <- result$contested

  nxt <- .next_phase(game$season, game$phase, nrow(result$dislodged) > 0L,
                     game$year)
  leaving_autumn <- game$season %in% c("Fall", "Winter") &&
    nxt$season == "Winter"
  if (leaving_autumn) game <- .update_sc_ownership(game)

  game$season <- nxt$season
  game$phase <- nxt$phase
  game$year <- as.integer(nxt$year)

  vc <- dp_victory_check(game)
  game$status$winner <- vc$winner
  game$status$outcome <- vc$outcome
  game$status$over <- vc$over
  validate_dp_game(game, call = call)
}
