
#' Enter Warcraft Mode
#'
#' Plays audio from Warcraft as you work. Expensive tasks get a "job's
#' done", failed tasks get an annoyed orc, and the rest is random peon
#' chatter.
#'
#' @param n Maximum number of top-level tasks before warcraft mode expires.
#'   Defaults to 500. Use \code{Inf} to last the whole session, or
#'   \code{FALSE} to leave warcraft mode.
#' @param p Probability that an ordinary top-level task triggers a random
#'   clip. Defaults to \code{0.1}, or roughly one task in ten.
#' @param min_time Tasks costing at least this many seconds of CPU time
#'   always get a "job's done", regardless of \code{p}. Defaults to 5. Set
#'   to \code{Inf} to switch this off and go back to purely random playback.
#' @param errors If \code{TRUE} (the default) a failed top-level task always
#'   plays an error clip. Requires R 4.0.0 or later.
#'
#' @examples
#' \dontrun{
#' ## load warcraft
#' library(warcraft)
#'
#' ## enter warcraft mode
#' warcraft_mode()
#'
#' ## only speak up for tasks that took real work (30+ CPU seconds)
#' warcraft_mode(Inf, p = 0, min_time = 30)
#'
#' ## play lots of warcraft sounds for entire R session
#' warcraft_mode(Inf, 1.0)
#'
#' ## disable warcraft mode
#' warcraft_mode(FALSE)
#' }
#' @return Invisibly returns the warcraft mode settings.
#' @seealso \code{\link{warcraft_play}}, \code{\link{warcraft_when_done}},
#'   \code{\link{warcraft_status}}
#' @export
warcraft_mode <- function(n = 500, p = 0.1, min_time = 5, errors = TRUE) {
  invisible(removeTaskCallback("warcraftmode"))
  remove_error_handler()
  if (identical(n, FALSE)) {
    options(warcraft_mode = FALSE)
    .w$settings <- NULL
    warcraft_play("done")
    return(invisible(NULL))
  }
  stopifnot(
    is.numeric(n), length(n) == 1L,
    is.numeric(p), length(p) == 1L, p >= 0, p <= 1,
    is.numeric(min_time), length(min_time) == 1L, min_time >= 0
  )
  if (!can_play()) {
    warning(
      "no audio player found; install sox (`play`) or run on macOS",
      call. = FALSE
    )
  }
  .w$settings <- list(n = n, p = p, min_time = min_time, errors = errors)
  options(warcraft_mode = TRUE)
  invisible(addTaskCallback(wc3(n, p, min_time), name = "warcraftmode"))
  if (errors) {
    add_error_handler()
  }
  message("Entering Warcraft mode...")
  warcraft_play("start")
  invisible(.w$settings)
}

#' @export
#' @rdname warcraft_mode
warcraft <- function(n = 500, p = 0.1, min_time = 5, errors = TRUE) {
  warcraft_mode(n, p, min_time, errors)
}

#' Warcraft mode status
#'
#' Report whether warcraft mode is on, how it is configured, and how many
#' clips are cached locally.
#'
#' @return The current settings, invisibly.
#' @examples
#' \dontrun{
#' warcraft_status()
#' }
#' @export
warcraft_status <- function() {
  on <- isTRUE(getOption("warcraft_mode"))
  s <- .w$settings
  x <- warcraft_files(download = FALSE)
  cat(
    "warcraft mode : ", if (on) "ON" else "off", "\n",
    "sounds        : ", sum(x$cached), "/", nrow(x), " cached in ",
    warcraft_dir(), "\n",
    "player        : ", if (can_play()) "found" else "NOT FOUND", "\n",
    "muted         : ", isTRUE(getOption("warcraft.mute", FALSE)), "\n",
    sep = ""
  )
  if (on && !is.null(s)) {
    cat(
      "plays left    : ", format(s$n - .w$ctr), "\n",
      "probability   : ", format(s$p), "\n",
      "min_time      : ", format(s$min_time), " CPU seconds\n",
      "error sounds  : ", s$errors, "\n",
      sep = ""
    )
  }
  invisible(s)
}

#' Announce when an expression finishes
#'
#' Runs \code{expr} and plays a clip when it is done: "job's done" on
#' success, an annoyed orc on failure. Unlike warcraft mode this times the
#' expression exactly, so it also works in scripts and inside functions.
#'
#' @param expr An expression to evaluate. Wrap several statements in
#'   \code{\{ \}}.
#' @param min_time Only announce if \code{expr} took at least this many
#'   seconds. Defaults to 0, meaning always announce.
#' @return The value of \code{expr}.
#' @examples
#' \dontrun{
#' ## tell me when the model is fit
#' fit <- warcraft_when_done(lm(mpg ~ ., mtcars))
#'
#' ## only speak up if the block took more than a minute
#' warcraft_when_done({
#'   big_download()
#'   slow_model()
#' }, min_time = 60)
#' }
#' @export
warcraft_when_done <- function(expr, min_time = 0) {
  t0 <- proc.time()[["elapsed"]]
  out <- tryCatch(expr, error = function(e) {
    if (proc.time()[["elapsed"]] - t0 >= min_time) {
      warcraft_play("error")
    }
    stop(e)
  })
  if (proc.time()[["elapsed"]] - t0 >= min_time) {
    warcraft_play("done")
  }
  out
}

#' Mute warcraft
#'
#' Silence every clip without tearing down warcraft mode. A thin wrapper
#' around \code{options(warcraft.mute = )}.
#'
#' @param mute Set to \code{FALSE} to unmute.
#' @return The previous mute setting, invisibly.
#' @examples
#' \dontrun{
#' warcraft_mute()
#' warcraft_mute(FALSE)
#' }
#' @export
warcraft_mute <- function(mute = TRUE) {
  old <- getOption("warcraft.mute", FALSE)
  options(warcraft.mute = mute)
  invisible(old)
}

.Renviron <- function() {
  if (file.exists(".Renviron")) {
    ".Renviron"
  } else if (!identical(Sys.getenv("HOME"), "")) {
    file.path(Sys.getenv("HOME"), ".Renviron")
  } else {
    file.path(normalizePath("~"), ".Renviron")
  }
}

home <- function() {
  if (!identical(Sys.getenv("HOME"), "")) {
    file.path(Sys.getenv("HOME"))
  } else {
    file.path(normalizePath("~"))
  }
}

wc3 <- function(total, p, min_time) {
  .w$ctr <- 0L
  last <- sum(proc.time()[1:2])
  function(expr, value, ok, visible) {
    .w$ctr <- .w$ctr + 1L
    now <- sum(proc.time()[1:2])
    ## CPU time rather than wall clock, so idling at the prompt costs nothing
    cost <- now - last
    last <<- now
    if (.w$ctr > total) {
      options(warcraft_mode = FALSE)
      .w$settings <- NULL
      remove_error_handler()
      message("Warcraft mode has expired.")
      warcraft_play("done")
      return(FALSE)
    }
    if (.w$ctr == 1L) {
      ## the warcraft_mode() call itself, already announced by "start"
      return(TRUE)
    }
    if (cost >= min_time) {
      warcraft_play("done")
    } else if (stats::runif(1) < p) {
      warcraft_play("task")
    }
    TRUE
  }
}

## task callbacks never run for a failed task, so errors need their own hook
add_error_handler <- function() {
  if (getRversion() < "4.0.0" || !is.null(.w$handlers)) {
    return(invisible(NULL))
  }
  .w$handlers <- globalCallingHandlers()
  globalCallingHandlers(error = function(e) try(warcraft_play("error"), silent = TRUE))
  invisible(NULL)
}

remove_error_handler <- function() {
  if (getRversion() < "4.0.0" || is.null(.w$handlers)) {
    return(invisible(NULL))
  }
  globalCallingHandlers(NULL)
  if (length(.w$handlers) > 0L) {
    do.call(globalCallingHandlers, .w$handlers)
  }
  .w$handlers <- NULL
  invisible(NULL)
}
