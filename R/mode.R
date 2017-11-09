
#' Enter Warcraft Mode
#'
#' @param n Maximum number of times to call warcraft audio before
#'   warcraft mode expires. Defaults to 500. To disable warcraft mode,
#'   set this value to FALSE.
#' @param p Desired proportion of top-level tasks that should trigger
#'   the playing of audio files. Defaults to play audio during roughly
#'   1 out of 10 top level tasks.
#'
#' @examples
#' \dontrun{
#' ## load warcraft
#' library(warcraft)
#'
#' ## enter warcraft mode
#' warcraft_mode()
#'
#' ## disable warcraft mode
#' warcraft_mode(FALSE)
#'
#' ## play lots of warcraft sounds for entire R session
#' warcraft_mode(Inf, 1.0)
#'
#' }
#' @return Invisibly enters warcraft_mode (getOption("warcraft_mode"))
#' @export
warcraft_mode <- function(n = 500, p = .1) {
  if (identical(n, FALSE)) {
    options(warcraft_mode = FALSE)
    invisible(removeTaskCallback("warcraftmode"))
    warcraft_("last")
  } else if (isTRUE(getOption("warcraft_mode"))) {
    invisible(removeTaskCallback("warcraftmode"))
    invisible(addTaskCallback(wc3(n, p), name = "warcraftmode"))
  } else {
    options(warcraft_mode = TRUE)
    invisible(addTaskCallback(wc3(n, p), name = "warcraftmode"))
  }
  invisible()
}

#' @export
#' @inheritParams warcraft_mode
#' @rdname warcraft_mode
warcraft <- function(n = 500, p = .1) warcraft_mode(n, p)

warcraft_dir <- function() {
  wardir <- Sys.getenv("WARCRAFT_DIR")
  if (identical(wardir, "")) {
    wardir <- file.path(home(), ".warcraft")
    set_renv("WARCRAFT_DIR" = wardir)
  }
  wardir
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

setup_warcraft_dir <- function() {
  if (exists(".w")) {
    return(get("wavs", envir = get(".w")))
  }
  wardir <- warcraft_dir()
  if (!dir.exists(wardir)) {
    dir.create(wardir)
  }
  wavs <- list.files(wardir, all.files = TRUE)
  if (any(!wc_sounds$path %in% wavs)) {
    kp <- !wc_sounds$path %in% wavs
    sh <- Map(
      "download.file",
      wc_sounds$url[!wc_sounds$path %in% wavs],
      file.path(wardir, wc_sounds$path[!wc_sounds$path %in% wavs])
    )
  }
  wavs <- list.files(
    warcraft_dir(), pattern = "\\.mp3$|\\.wav$",
    full.names = TRUE, all.files = TRUE
  )
  .w <- new.env()
  assign("wavs", wavs, envir = .w)
}

wc3 <- function(total, p) {
  ## create counter
  ..ctr.. <- 0L
  function(expr, value, ok, visible) {
    ## add to counter
    ..ctr.. <<- ..ctr.. + 1L
    active <- (..ctr.. <= total)
    if (!active) {
      warcraft_("last")
      options(warcraft_mode = FALSE)
      message("Warcraft mode has expired.")
    } else if (..ctr.. == 1L) {
      options(warcraft_mode = TRUE)
      message("Entering Warcraft mode...")
      warcraft_("first")
    } else if (runif(1) > (1 - p)) {
      ## warcraft mode
      warcraft_("mid")
    }
    ## return
    active
  }
}

warcraft_ <- function(which = "mid") {
  wavs <- setup_warcraft_dir()
  if (which == "first") {
    wav <- grep("\\.ready", wavs, value = TRUE)
  } else if (which == "last") {
    wav <- grep("\\.jobsdone", wavs, value = TRUE)
  } else {
    wav <- sample(
      grep("\\.ready|\\.jobsdone", wavs, value = TRUE, invert = TRUE),
      1L
    )
  }
  if (.Platform$OS.type == "windows") {
    player <- "c:/Program Files/Windows Media Player/wmplayer.exe"
    if (!file.exists(player)) {
      player <- "mplay32 /play /close"
    } else {
      player <- shQuote(player)
    }
    sh <- shell(paste0('"', paste(player, shQuote(wav)), '"'), intern = TRUE)
  } else if (file.exists("/usr/bin/afplay")) {
    player <- "afplay"
    sh <- system(paste(player, wav, "&"), intern = TRUE)
  } else {
    player <- "play"
    sh <- system(paste(player, wav, "&"), intern = TRUE)
  }
  invisible()
}
