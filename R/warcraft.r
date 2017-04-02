
#' warcraft mode
#'
#' @param n Number of max times to call warcraft audio before
#'   warcraft mode expires. Defaults to 500. Plays roughly 1
#'   out of 10 top level tasks.
#' @export
warcraft_mode <- function(n = 500) {
    addTaskCallback(wc3(n))
}

wc3 <- function(total) {
    ## create counter
    ..ctr.. <- 0
    function() {
        ## add to counter
        ..ctr.. <<- ..ctr.. + 1
        ## warcraft mode
        warcraft()
        active <- (..ctr.. < total)
        if (!active) {
            options(warcraft_mode = FALSE)
            message("warcraft mode expired")
        }
        ## return
        active
    }
}

warcraft <- function() {
    mp3s <- WARCRAFT_PATH()
    if (identical(mp3s, FALSE)) {
        mp3s <- grep("^.*-warcraft.mp3$",
                     list.files(all.files = TRUE, full.names = TRUE),
                     value = TRUE)
        if (length(mp3s == 0)) {
            stop("sorry, you'll need to download the warcraft audio files",
                 call. = FALSE)
        }
    }
    mp3 <- sample(mp3s, 1)
    if (isTRUE(getOption("warcraft_mode")) & runif(1) < .05) {
        system(paste("afplay", mp3, "&"))
    } else {
        packageStartupMessage("Entering warcraft mode...")
        options(warcraft_mode = TRUE)
        system(paste("afplay", mp3, "&"))
    }
    TRUE
}

WARCRAFT_PATH <- function() {
    x <- Sys.getenv("WARCRAFT_PATH")
    if (identical(x, "")) return(FALSE)
    strsplit(x, ":")[[1]]
}


#' warcraft
#'
#' Set your R environment to warcraft mode
#' @examples
#' \dontrun{
#' ## for setup instructions see README which you can find
#' ## https://github.com/mkearney/warcraft/blob/master/README.md
#' ## to enter warcraft mode
#' library(warcraft)
#'
#' ## to re-enter or to prevent expiration in a session
#' warcraft_mode(Inf)
#' }
#'
#' @docType package
#' @name warcraft
.onAttach <- function(libname, pkgname) {
    warcraft_mode()
}
