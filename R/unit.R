# Units -----------------------------------------------------------------------

#' Describe a unit
#'
#' Builds the one-row tibble the package uses to represent a single army or
#' fleet. Fleets on a split-coast province must give the coast explicitly, for
#' example `"spa/nc"`; if the coast is omitted and the province has exactly one
#' coast reachable in the board graph, it is filled in.
#'
#' @param power Owning power, for example `"France"`.
#' @param type `"army"` or `"fleet"`.
#' @param loc Location code, for example `"par"` or `"spa/nc"`.
#' @param map A [dp_map] object used to validate the location.
#' @param call Caller environment, for error reporting. Experts only.
#' @return A one-row tibble with columns `power`, `type` and `loc`.
#' @export
#' @family setup
#' @examples
#' dp_unit("France", "army", "par")
#' dp_unit("Russia", "fleet", "stp/sc")
dp_unit <- function(power, type, loc, map = dp_map(),
                    call = rlang::caller_env()) {
  .check_class(map, "dp_map", call = call)
  .check_string(type, call = call)
  .check_string(loc, call = call)
  power <- .match_power(power, map$powers, call = call)
  type <- rlang::arg_match(type, c("army", "fleet"), error_call = call)
  loc <- .normalise_loc(map, tolower(loc), type, call = call)
  tibble::tibble(power = power, type = type, loc = loc)
}

#' Normalise a unit location
#'
#' Validates that a location can hold a unit of the given type and fills in an
#' unambiguous coast for fleets.
#'
#' @param map A [dp_map] object.
#' @param loc Location code.
#' @param type `"army"` or `"fleet"`.
#' @param call Caller environment, for error reporting.
#' @return A normalised location code.
#' @noRd
.normalise_loc <- function(map, loc, type, call = rlang::caller_env()) {
  prov <- .province(loc)
  if (!prov %in% map$provinces$code) {
    cli::cli_abort("Unknown province {.val {prov}}.", call = call)
  }
  ptype <- .province_type(map, prov)
  if (type == "army") {
    if (ptype == "sea") {
      cli::cli_abort(
        "An army cannot occupy the sea province {.val {prov}}.",
        call = call
      )
    }
    return(prov)
  }
  if (ptype == "land") {
    cli::cli_abort(
      "A fleet cannot occupy the inland province {.val {prov}}.",
      call = call
    )
  }
  cs <- .coasts_of(map, prov)
  if (length(cs) == 0L) return(prov)
  if (loc %in% cs) return(loc)
  if (length(cs) == 1L) return(cs)
  cli::cli_abort(
    c("A fleet in {.val {prov}} must name a coast.",
      i = "Use one of {.val {cs}}."),
    call = call
  )
}

#' Locate the unit standing in a province
#'
#' @param units A units tibble.
#' @param province A province code (coasts are ignored).
#' @return A one-row tibble, or a zero-row tibble when the province is empty.
#' @noRd
.unit_at <- function(units, province) {
  units[.province(units$loc) %in% province, , drop = FALSE]
}

#' Index of the unit standing in each province
#'
#' @param units A units tibble.
#' @param province Character vector of province codes.
#' @return An integer vector of row indices, `NA` where the province is empty.
#' @noRd
.unit_index <- function(units, province) {
  match(province, .province(units$loc))
}

#' Can a unit of this type move between two locations?
#'
#' @param map A [dp_map] object.
#' @param type `"army"` or `"fleet"`.
#' @param from Source location.
#' @param to Destination location.
#' @return `TRUE` when the step is legal on the board graph.
#' @noRd
.can_step <- function(map, type, from, to) {
  if (type == "army") {
    return(.province(to) %in% (map$army_adj[[.province(from)]] %||%
                                 character(0)))
  }
  adj <- map$fleet_adj[[from]] %||% character(0)
  to %in% adj
}

#' Fleet destinations from a location, including named coasts
#'
#' @param map A [dp_map] object.
#' @param from Source location.
#' @return A character vector of legal fleet destinations.
#' @noRd
.fleet_moves <- function(map, from) map$fleet_adj[[from]] %||% character(0)
