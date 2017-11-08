
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
    invisible(removeTaskCallback("warcraft_"))
    message("leaving warcraft mode...")
  } else if (isTRUE(getOption("warcraft_mode"))) {
    invisible(removeTaskCallback("warcraft_"))
    invisible(addTaskCallback(wc3(n, p), name = "warcraft_"))
  } else {
    invisible(addTaskCallback(wc3(n, p), name = "warcraft_"))
  }
  invisible()
}

#' @export
#' @inheritParams warcraft_mode
#' @rdname warcraft_mode
warcraft <- function(n = 500, p = .1) warcraft_mode(n, p)


WARCRAFT_DIR <- function(home) {
  x <- Sys.getenv("WARCRAFT_DIR")
  if (identical(x, "")) {
    save_dir2renv(home)
    x <- Sys.getenv("WARCRAFT_DIR")
    if (identical(x, "")) {
      stop("save_dir2renv() didn't work", call. = FALSE)
    }
  }
  x
}

setup_warcraft <- function(home = normalizePath("~/")) {
  wardir <- WARCRAFT_DIR(home)
  stopifnot(dir.exists(wardir))
  x <- list.files(wardir, all.files = TRUE)
  if (any(!wc_sounds$path %in% x)) {
    kp <- !wc_sounds$path %in% x
    sh <- Map(
      "download.file",
      wc_sounds$url[kp],
      file.path(wardir, wc_sounds$path[kp])
    )
  }
  invisible()
}

wc3 <- function(total, p) {
  ## create counter
  ..ctr.. <- 0L
  function(expr, value, ok, visible) {
    ## add to counter
    ..ctr.. <<- ..ctr.. + 1L
    ## warcraft mode
    warcraft_(p)
    active <- (..ctr.. < total)
    if (!active) {
      options(warcraft_mode = FALSE)
      message("warcraft mode expired")
    }
    ## return
    active
  }
}

oldwarcraft_ <- function(p) {
  wardir <- WARCRAFT_DIR()
  mp3s <- list.files(
    wardir, "\\.warcraft\\.mp3$", all.files = TRUE, full.names = TRUE)
  if (length(mp3s) == 0) {
    stop("sorry, you'll need to download the warcraft audio files",
         call. = FALSE)
  }
  mp3 <- sample(mp3s, 1)
  if (isTRUE(getOption("warcraft_mode"))) {
    if (runif(1) < p) {
      if (.Platform$OS.type == "windows") {
        stop("Sorry. Doesn't work on Windows", call. = FALSE)
      } else {
        player <- "afplay"
      }
      system(paste(player, mp3, "&"))
    }
  } else {
    message("Entering warcraft mode...")
    options(warcraft_mode = TRUE)
    if (.Platform$OS.type == "windows") {
      stop("Sorry. Doesn't work on Windows", call. = FALSE)
    } else {
      player <- "afplay"
    }
    system(paste(player, mp3, "&"))
  }
  TRUE
}


warcraft_ <- function(p) {
  wardir <- WARCRAFT_DIR()
  mp3s <- list.files(
    wardir, "\\.warcraft\\.mp3$", all.files = TRUE, full.names = TRUE)
  if (length(mp3s) == 0) {
    stop("sorry, you'll need to download the warcraft audio files",
         call. = FALSE)
  }
  mp3 <- sample(mp3s, 1)
  if (isTRUE(getOption("warcraft_mode"))) {
    if (runif(1) < p) {
      if (.Platform$OS.type == "windows") {
        player <- "c:/Program Files/Windows Media Player/wmplayer.exe"
        if (!file.exists(player)) {
          player <- "mplay32 /play /close"
        } else {
          player <- shQuote(player)
        }
        shell(paste0('"', paste(player, shQuote(mp3)), '"'))
      } else if (file.exists("/usr/bin/afplay")) {
        player <- "afplay"
        system(paste(player, mp3, "&"))
      } else {
        player <- "play"
        system(paste(player, mp3, "&"))
      }
    }
  } else {
    message("Entering warcraft mode...")
    options(warcraft_mode = TRUE)
    if (.Platform$OS.type == "windows") {
      player <- "c:/Program Files/Windows Media Player/wmplayer.exe"
      if (!file.exists(player)) {
        player <- "mplay32 /play /close"
      } else {
        player <- shQuote(player)
      }
      shell(paste0('"', paste(player, shQuote(mp3)), '"'))
    } else if (file.exists("/usr/bin/afplay")) {
      player <- "afplay"
      system(paste(player, mp3, "&"))
    } else {
      player <- "play"
      system(paste(player, mp3, "&"))
    }
  }
  TRUE
}
