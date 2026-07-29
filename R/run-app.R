# Shiny launcher ---------------------------------------------------------------

#' Launch the diplomacyR application
#'
#' Opens the bundled \pkg{shiny} application: an interactive board, an order
#' editor with live legality checking, a turn adjudicator, a replayable
#' history, analysis charts and a batch-simulation runner.
#'
#' @param ... Passed to [shiny::runApp()], for example `port` or `launch.browser`.
#' @param call Caller environment, for error reporting. Experts only.
#' @return Invisibly `NULL`. Called for the side effect of running the app.
#' @export
#' @family app
#' @examples
#' \donttest{
#' if (interactive()) {
#'   dp_run_app()
#' }
#' }
dp_run_app <- function(..., call = rlang::caller_env()) {
  needed <- c("shiny", "bslib", "DT")
  missing <- needed[!vapply(needed, requireNamespace, logical(1),
                            quietly = TRUE)]
  if (length(missing) > 0L) {
    cli::cli_abort(
      c("The application needs {?package/packages} {.pkg {missing}}.",
        i = 'Install {?it/them} with {.code install.packages(c({paste0(dQuote(missing, FALSE), collapse = ", ")}))}.'),
      call = call
    )
  }
  app_dir <- system.file("shiny", "diplomacyR", package = "diplomacyR")
  if (!nzchar(app_dir)) {
    cli::cli_abort("Could not find the application directory.", call = call)
  }
  shiny::runApp(app_dir, ...)
  invisible(NULL)
}
