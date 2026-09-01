

#' warcraft: Turn on Warcraft Mode in your R environment
#'
#' Plays audio from the classic computer game while you work: a "job's
#' done" when a task took real effort, an annoyed orc when it failed, and
#' random peon chatter the rest of the time. Requires \code{afplay}
#' (macOS) or one of \code{play}, \code{paplay}, or \code{aplay} (linux).
#'
#' @section Options:
#' \describe{
#'   \item{\code{warcraft.mute}}{Set to \code{TRUE} to silence every clip.}
#'   \item{\code{warcraft.volume}}{Playback volume, where \code{1} is normal.}
#' }
"_PACKAGE"

.onAttach <- function(libname, pkgname) {
  ## never hit the network in scripts, CI, or R CMD check
  if (interactive()) {
    try(warcraft_files(), silent = TRUE)
  }
}
