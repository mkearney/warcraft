
save_dir2renv <- function(home) {
  ## create dir and .Renviron paths
  dir <- file.path(home, ".warcraft")
  renv <- file.path(home, ".Renviron")
  ## check whether dir exists and create if not
  if (!dir.exists(dir)) {
    dir.create(dir)
  }
  ## check .Renviron
  check_renv(renv)
  ## set dir path as R environment variable
  set_renv(`WARCRAFT_DIR` = dir, path = renv)
}

check_renv <- function(path) {
  if (!file.exists(path)) {
    return(invisible())
  }
  con <- file(path)
  x <- readLines(con, warn = FALSE)
  close(con)
  x <- clean_renv(x)
  x <- paste(x, collapse = "\n")
  cat(x, file = path, fill = TRUE)
  invisible()
}

clean_renv <- function(x) {
  stopifnot(is.character(x))
  ## remove incomplete vars
  x <- grep("=$", x, value = TRUE, invert = TRUE)
  ## split lines with double entries and fix into new vars
  xs <- strsplit(x, "=")
  vals <- sub("[^=]*=", "", x)
  kp <- !grepl("[[:upper:]]{1,}=", vals)
  if (sum(!kp) > 0L) {
    m <- regexpr("[[:upper:]_]{1,}(?==)", x[!kp], perl = TRUE)
    newlines <- paste0(regmatches(x[!kp], m), "=", sub(".*=", "", x[!kp]))
    x <- x[kp]
    x[(length(x) + 1):(length(x) + length(newlines))] <- newlines
  }
  ## remove double entries
  xs <- strsplit(x, "=")
  kp <- !duplicated(sapply(xs, "[[", 1))
  x <- x[kp]
  x
}

set_renv <- function(..., path) {
  dots <- list(...)
  nms <- names(dots)
  stopifnot(length(nms) > 0L)
  stopifnot(length(dots) == length(nms))
  x <- paste0(nms, "=", dots)
  x <- paste(x, collapse = "\n")
  check_renv(path)
  cat(x, file = path, fill = TRUE, append = TRUE)
  readRenviron(path)
}
