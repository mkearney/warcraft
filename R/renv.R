is_named <- function(x) UseMethod("is_named")
is_named.default <- function(x) !is.null(names(x))

are_named <- function(x) UseMethod("are_named")
are_named.default <- function(x) is_named(x) & !"" %in% names(x)


readlines <- function(x, ...) {
  con <- file(x)
  x <- readLines(con, warn = FALSE, ...)
  close(con)
  x
}

writelines <- function(x, file, ...) {
  con <- file(file)
  writeLines(x, con, ...)
  close(con)
}

check_renv <- function() {
  x <- readlines(.Renviron())
  ## split lines with double entries and fix into new vars
  x <- strsplit(x, "(?!<\\=)\\=", perl = TRUE)
  x <- x[lengths(x) == 2L]
  x <- tibble::as_tibble(data.frame(
    matrix(unlist(x), ncol = 2L, byrow = TRUE),
    stringsAsFactors = FALSE
  ), validate = FALSE)
  names(x) <- c("variable", "value")
  x <- x[!duplicated(x$variable, fromLast = TRUE), ]
  x <- paste0(x$variable, "=", x$value)
  suppressMessages(writelines(x, .Renviron()))
}

set_renv <- function(...) {
  dots <- list(...)
  stopifnot(are_named(dots))
  x <- paste0(names(dots), "=", dots)
  x <- paste(x, collapse = "\n")
  check_renv()
  cat(x, file = .Renviron(), fill = TRUE, append = TRUE)
  readRenviron(.Renviron())
}
