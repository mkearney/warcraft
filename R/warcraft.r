

#' warcraft: Turn on Warcraft Mode in your R environment
#'
#' Playing audio files from the classic computer game during
#' random top-level R tasks. Sorry, only works for Macs/linux
#' based operating systems.
"_PACKAGE"


.onAttach <- function(libname, pkgname) {
  wavs <- setup_warcraft_dir()
}
