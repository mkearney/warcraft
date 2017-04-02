
#' warcraft_mode
#'
#' @param n Number of max times to call warcraft audio before
#'   warcraft mode expires. Defaults to 500. Plays roughly 1
#'   out of 10 top level tasks. To disable warcraft mode, set
#'   this value to FALSE.
#' @export
#' @examples
#' \dontrun{
#' ## get home directory
#' home <- path.expand("~/")
#'
#' ## install audio and save key
#' warcraft::setup_warcraft(home)
#'
#' ## enter warcraft mode
#' library(warcraft)
#'
#' ## set for entire session
#' warcraft_mode(Inf)
#'
#' ## disable warcraft mode
#' warcraft_mode(FALSE)
#' }
warcraft_mode <- function(n = 500) {
    if (identical(n, FALSE)) options(warcraft_mode = FALSE)
    invisible(addTaskCallback(wc3(n)))
}


#' setup_warcraft
#'
#' @param home Computer's home directory. You can find this by entering
#'   \code{path.expand("~/")} into your console.
#' @export
#' @examples
#' \dontrun{
#' ## get home directory
#' home <- path.expand("~/")
#'
#' ## install audio and save key
#' warcraft::setup_warcraft(home)
#'
#' ## enter warcraft mode
#' library(warcraft)
#'
#' ## set for entire session
#' warcraft_mode(Inf)
#'
#' ## disable warcraft mode
#' warcraft_mode(FALSE)
#' }
setup_warcraft <- function(home) {
    if (missing(home)) stop("must provide home directory", call. = FALSE)
    stopifnot(is.character(home))
    mapply(download.file, wc_sounds$url,
           file.path(home, wc_sounds$path))
    key <- paste(file.path(home, wc_sounds$path), collapse = ":")
    cat("WARCRAFT_PAT=", key, file = file.path(home, ".Renviron"),
        fill = TRUE, append = TRUE)
}


wc3 <- function(total) {
    ## create counter
    ..ctr.. <- 0
    function(expr, value, ok, visible) {
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
    mp3s <- WARCRAFT_PAT()
    if (identical(mp3s, FALSE)) {
        mp3s <- grep("^.*.warcraft$",
                     list.files(all.files = TRUE, full.names = TRUE),
                     value = TRUE)
        if (length(mp3s == 0)) {
            stop("sorry, you'll need to download the warcraft audio files",
                 call. = FALSE)
        }
    }
    mp3 <- sample(mp3s, 1)
    if (isTRUE(getOption("warcraft_mode"))) {
        if (runif(1) < .05) system(paste("afplay", mp3, "&"))
    } else {
        packageStartupMessage("Entering warcraft mode...")
        options(warcraft_mode = TRUE)
        system(paste("afplay", mp3, "&"))
    }
    TRUE
}

WARCRAFT_PAT <- function() {
    x <- Sys.getenv("WARCRAFT_PAT")
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
