# _build.R --------------------------------------------------------------------
# The canonical build for diplomacyR. Run from the package root.

pkgs <- c("devtools", "roxygen2", "pkgdown", "spelling")
missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0L) {
  stop("Install first: ", paste(missing, collapse = ", "), call. = FALSE)
}

# 1. Regenerate the shipped data from source.
source("data-raw/standard_map.R")
source("data-raw/datc_cases.R")

# 2. Documentation and namespace.
devtools::document()

# 3. Tests.
devtools::test()

# 4. Prose.
if (file.exists("README.Rmd")) knitr::knit("README.Rmd", "README.md")
devtools::build_vignettes()

# 5. The CRAN gate.
devtools::check(args = c("--as-cran", "--no-manual"))

# 6. The website.
pkgdown::build_site(preview = FALSE)
