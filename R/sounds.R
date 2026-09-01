## cache of the resolved sound catalog, populated by warcraft_files()
.w <- new.env(parent = emptyenv())

warcraft_dir <- function() {
  wardir <- Sys.getenv("WARCRAFT_DIR")
  if (identical(wardir, "")) {
    wardir <- file.path(home(), ".warcraft")
    set_renv("WARCRAFT_DIR" = wardir)
  }
  wardir
}

#' Warcraft sounds
#'
#' The catalog of audio clips available to warcraft mode, along with the
#' local file each one resolves to. Clips are downloaded once into
#' \code{Sys.getenv("WARCRAFT_DIR")} and reused from then on.
#'
#' @param download If \code{TRUE} (the default) any clips missing from the
#'   local cache are downloaded first.
#' @return A data frame with one row per clip: \code{name}, \code{category}
#'   (\code{"start"}, \code{"task"}, \code{"done"}, or \code{"error"}),
#'   \code{file}, and \code{cached}.
#' @examples
#' \dontrun{
#' warcraft_sounds()
#' }
#' @export
warcraft_sounds <- function(download = TRUE) {
  x <- warcraft_files(download = download)
  x[c("name", "category", "file", "cached")]
}

warcraft_files <- function(download = TRUE) {
  if (!is.null(.w$files) && all(.w$files$cached)) {
    return(.w$files)
  }
  wardir <- warcraft_dir()
  if (!dir.exists(wardir)) {
    dir.create(wardir, recursive = TRUE, showWarnings = FALSE)
  }
  x <- wc_sounds
  x$file <- file.path(wardir, x$path)
  x$cached <- file.exists(x$file)
  if (download && any(!x$cached)) {
    for (i in which(!x$cached)) {
      ## one dead url must not take the rest of the library down with it
      ok <- tryCatch(
        utils::download.file(
          x$url[i], x$file[i], mode = "wb", quiet = TRUE
        ) == 0L,
        error = function(e) FALSE,
        warning = function(w) FALSE
      )
      if (!ok && file.exists(x$file[i])) {
        file.remove(x$file[i])
      }
    }
    x$cached <- file.exists(x$file)
  }
  .w$files <- x
  x
}

#' Play a warcraft sound
#'
#' Play a clip on demand -- handy at the end of a long script or inside a
#' loop, whether or not warcraft mode is switched on.
#'
#' @param what Either a category (\code{"task"}, the default, \code{"start"},
#'   \code{"done"}, or \code{"error"}) or the \code{name} of a specific clip
#'   as listed by \code{\link{warcraft_sounds}}. A random clip is drawn when
#'   \code{what} names a category.
#' @param volume Playback volume, where \code{1} is normal. Defaults to
#'   \code{getOption("warcraft.volume")}.
#' @return The path of the clip that was played, invisibly, or \code{NULL} if
#'   nothing could be played.
#' @examples
#' \dontrun{
#' ## announce the end of a long job
#' warcraft_play("done")
#'
#' ## play one specific clip
#' warcraft_play("workwork")
#' }
#' @export
warcraft_play <- function(what = "task", volume = NULL) {
  if (isTRUE(getOption("warcraft.mute", FALSE))) {
    return(invisible(NULL))
  }
  x <- warcraft_files()
  x <- x[x$cached, , drop = FALSE]
  pool <- x$file[x$category %in% what | x$name %in% what]
  if (length(pool) == 0L) {
    ## unknown category, or nothing downloaded yet -- fall back to anything
    pool <- x$file
  }
  if (length(pool) == 0L) {
    return(invisible(NULL))
  }
  wav <- pool[sample.int(length(pool), 1L)]
  play_file(wav, volume = volume)
  invisible(wav)
}

play_file <- function(file, volume = NULL) {
  if (is.null(volume)) {
    volume <- getOption("warcraft.volume", 1)
  }
  if (.Platform$OS.type == "windows") {
    player <- "c:/Program Files/Windows Media Player/wmplayer.exe"
    if (!file.exists(player)) {
      player <- "mplay32 /play /close"
    } else {
      player <- shQuote(player)
    }
    shell(paste0('"', paste(player, shQuote(file)), '"'), wait = FALSE)
    return(invisible(NULL))
  }
  cmd <- if (nzchar(Sys.which("afplay"))) {
    paste("afplay -v", format(volume), shQuote(file))
  } else if (nzchar(Sys.which("play"))) {
    paste("play -q -v", format(volume), shQuote(file))
  } else if (nzchar(Sys.which("paplay"))) {
    paste("paplay", shQuote(file))
  } else if (nzchar(Sys.which("aplay"))) {
    paste("aplay -q", shQuote(file))
  } else {
    return(invisible(NULL))
  }
  ## wait = FALSE so audio never blocks the console
  system(cmd, wait = FALSE, ignore.stdout = TRUE, ignore.stderr = TRUE)
  invisible(NULL)
}

can_play <- function() {
  if (isTRUE(getOption("warcraft.mute", FALSE))) {
    return(FALSE)
  }
  if (.Platform$OS.type == "windows") {
    return(TRUE)
  }
  any(nzchar(Sys.which(c("afplay", "play", "paplay", "aplay"))))
}
