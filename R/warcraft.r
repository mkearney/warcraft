warcraft3 <- function(download = FALSE) {
    mp3s <- WARCRAFT_PATH()
    if (identical(mp3s, FALSE)) {
        mp3s <- grep("^.*-warcraft.mp3$",
                     list.files(all.files = TRUE, full.names = TRUE),
                     value = TRUE)
        if (length(mp3s == 0) & download) {
            warning("could not find ^.*-warcraft.mp3$ files.",
                    call. = FALSE)
            message("installing warcraft3 audio files...")
            download.file("https://dl.dropboxusercontent.com/u/94363099/.icandothat-warcraft.mp3",
                          ".icandothat-warcraft3.mp3")
            download.file("https://dl.dropboxusercontent.com/u/94363099/.workwork-warcraft.mp3",
                          ".workwork-warcraft.mp3")
            download.file("https://dl.dropboxusercontent.com/u/94363099/.jobsdone-warcraft.mp3",
                          ".jobsdone-warcraft.mp3")
            mp3s <- grep("^.*-warcraft.mp3$",
                         list.files(all.files = TRUE, full.names = TRUE),
                         value = TRUE)
            mp3s <- paste(mp3s, collapse = ":")
            Sys.setenv(WARCRAFT_PATH = mp3s)
        } else {
            stop("sorry, you'll need to download the warcraft audio files",
                 call. = FALSE)
        }
    }
    if (runif(1) < .10) {
        mp3 <- sample(mp3s, 1)
        system(paste("afplay", mp3, "&"))
    }
    TRUE
}


WARCRAFT_PATH <- function() {
    x <- Sys.getenv("WARCRAFT_PATH")
    if (identical(x, "")) return(FALSE)
    strsplit(x, ":")[[1]]
}

#' jobsdone_wrappper
#' @param n Number of max times to call warcraft audio before
#'   warcraft mode expires. Defaults to 100. Plays roughly 1
#'   out of 10 top level tasks.
#' @export
warcraft_mode <- function(n = 100) {
    addTaskCallback(wc3(n))
}

wc3 <- function(total = 10) {
  ctr <- 0
  function(expr, value, ok, visible) {
      ctr <<- ctr + 1
      warcraft3()
      keep.me <- (ctr < total)
      if (!keep.me)
          message("warcraft mode expired")

      ## return
      keep.me
  }
}

.onAttach <- function(libname, pkgname) {
    packageStartupMessage("Entering warcraft mode...")
    warcraft_mode()
}
