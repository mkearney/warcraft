## warcraft
The only R package you need.

## description
Plays audio from warcraft 3 upon completion of every few R tasks.

## install

``` r
if (!"devtools" %in% installed.packages()) {
    install.packages("devtools")
}
devtools::install_github("mkearney/warcraft")
```

## setup

``` r
## get home directory
home <- path.expand("~/")

## download audio files
download.file("https://dl.dropboxusercontent.com/u/94363099/.icandothat-warcraft.mp3",
              file.path(home, ".icandothat-warcraft3.mp3"))
download.file("https://dl.dropboxusercontent.com/u/94363099/.workwork-warcraft.mp3",
              file.path(home, ".workwork-warcraft.mp3"))
download.file("https://dl.dropboxusercontent.com/u/94363099/.jobsdone-warcraft.mp3",
              file.path(home, ".jobsdone-warcraft.mp3"))

## create environment variable (string with audio paths)
mp3s <- grep("^.*-warcraft.mp3$",
    list.files(home, all.files = TRUE, full.names = TRUE),
    value = TRUE)
mp3s <- paste(mp3s, collapse = ":")

## save to .Renviron
cat(paste0("WARCRAFT_PATH=", mp3s),
    file = file.path(home, ".Renviron"),
    fill = TRUE, append = TRUE)
```

## use

``` r
## load package
library(warcraft)
```

## endless use

``` r
## play warcraft audio until q() session
warcraft_mode(Inf)
```
