# Printing ---------------------------------------------------------------------

#' @export
print.dp_map <- function(x, ...) {
  rlang::check_dots_empty()
  ty <- table(x$provinces$type)
  cli::cli_text("{.cls dp_map} {.val {x$name}}")
  cli::cli_bullets(c(
    "*" = "{nrow(x$provinces)} provinces \\
           ({ty[['land']]} inland, {ty[['coast']]} coastal, {ty[['sea']]} sea)",
    "*" = "{length(x$supply_centres)} supply centres, \\
           {nrow(x$start_units)} starting units",
    "*" = "{length(x$powers)} powers: {.val {x$powers}}"
  ))
  invisible(x)
}

#' @export
format.dp_map <- function(x, ...) {
  paste0("<dp_map: ", x$name, ", ", nrow(x$provinces), " provinces>")
}

#' @export
print.dp_game <- function(x, ...) {
  rlang::check_dots_empty()
  cli::cli_text("{.cls dp_game} {x$season} {x$year} ({x$phase} phase)")
  counts <- dp_power_counts(x)
  lines <- sprintf(
    "%-8s %2d centre%s  %2d unit%s",
    counts$power, counts$centres, ifelse(counts$centres == 1L, " ", "s"),
    counts$units, ifelse(counts$units == 1L, " ", "s")
  )
  cli::cli_verbatim(lines)
  if (nrow(x$dislodged) > 0L) {
    cli::cli_alert_warning(
      "{nrow(x$dislodged)} dislodged unit{?s} awaiting retreat."
    )
  }
  if (isTRUE(x$status$over) && !is.na(x$status$winner)) {
    cli::cli_alert_success("{x$status$winner} has won a solo victory.")
  }
  invisible(x)
}

#' @export
format.dp_game <- function(x, ...) {
  paste0("<dp_game: ", .turn_label(x), ", ", nrow(x$units), " units>")
}

#' @export
summary.dp_game <- function(object, ...) {
  rlang::check_dots_empty()
  dp_power_summary(object)
}

#' @export
print.dp_orders <- function(x, ...) {
  if (nrow(x) == 0L) {
    cli::cli_text("{.cls dp_orders} (no orders)")
    return(invisible(x))
  }
  cli::cli_text("{.cls dp_orders} ({nrow(x)} order{?s})")
  txt <- format(x)
  shown <- utils::head(txt, 20L)
  if ("success" %in% names(x)) {
    mark <- ifelse(is.na(x$success), " ",
                   ifelse(x$success, cli::symbol$tick, cli::symbol$cross))
    shown <- paste(utils::head(mark, 20L), shown)
  }
  cli::cli_verbatim(shown)
  if (length(txt) > 20L) {
    cli::cli_text("{.emph ... and {length(txt) - 20L} more}")
  }
  invisible(x)
}

#' @export
summary.dp_orders <- function(object, ...) {
  rlang::check_dots_empty()
  tab <- table(object$power, object$type)
  tibble::as_tibble(as.data.frame(tab, stringsAsFactors = FALSE)) |>
    stats::setNames(c("power", "type", "n"))
}

#' @export
print.dp_result <- function(x, ...) {
  rlang::check_dots_empty()
  cli::cli_text(
    "{.cls dp_result} {x$season} {x$year} ({x$phase} phase)"
  )
  ok <- sum(x$orders$success, na.rm = TRUE)
  cli::cli_bullets(c(
    "*" = "{ok} of {nrow(x$orders)} order{?s} succeeded",
    "*" = "{nrow(x$dislodged)} unit{?s} dislodged",
    "*" = "{length(x$contested)} province{?s} left contested"
  ))
  if (nrow(x$disbanded) > 0L) {
    cli::cli_bullets(c("*" = "{nrow(x$disbanded)} unit{?s} disbanded"))
  }
  if (nrow(x$built) > 0L) {
    cli::cli_bullets(c("*" = "{nrow(x$built)} unit{?s} built"))
  }
  invisible(x)
}

#' @export
format.dp_result <- function(x, ...) {
  paste0("<dp_result: ", x$season, " ", x$year, " ", x$phase, ">")
}

#' @export
summary.dp_result <- function(object, ...) {
  rlang::check_dots_empty()
  tibble::as_tibble(object$orders)
}

#' @export
print.dp_history <- function(x, ...) {
  rlang::check_dots_empty()
  cli::cli_text("{.cls dp_history} ({length(x)} turn{?s})")
  if (length(x) > 0L) {
    first <- x$turns[[1]]
    last <- x$turns[[length(x)]]
    cli::cli_bullets(c(
      "*" = "From {first$season} {first$year} to {last$season} {last$year}",
      "*" = "Outcome: {.val {x$outcome %||% NA_character_}}"
    ))
    if (!is.null(x$winner) && !is.na(x$winner)) {
      cli::cli_bullets(c("*" = "Winner: {.val {x$winner}}"))
    }
  }
  invisible(x)
}

#' @export
format.dp_history <- function(x, ...) {
  paste0("<dp_history: ", length(x), " turns>")
}

#' @export
summary.dp_history <- function(object, ...) {
  rlang::check_dots_empty()
  dp_power_summary(object)
}

#' @export
print.dp_sim <- function(x, ...) {
  rlang::check_dots_empty()
  cli::cli_text("{.cls dp_sim} ({nrow(x$games)} game{?s})")
  if (nrow(x$games) > 0L) {
    out <- dp_stats(x, "outcome")
    cli::cli_verbatim(sprintf("%-6s %4d (%.0f%%)", out$outcome, out$games,
                              100 * out$share))
  }
  cli::cli_bullets(c(
    "*" = "Bots: {.val {x$settings$bots}}",
    "*" = "Turn cap: {x$settings$max_years} year{?s}"
  ))
  invisible(x)
}

#' @export
format.dp_sim <- function(x, ...) {
  paste0("<dp_sim: ", nrow(x$games), " games>")
}

#' @export
summary.dp_sim <- function(object, ...) {
  rlang::check_dots_empty()
  dp_stats(object, "power")
}
