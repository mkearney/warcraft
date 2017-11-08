## load the first scriptorium emporium
lib(warcraft)


## build package
make_package(update = "patch", load_all = FALSE)



kp <- grep("[[:digit:]]\\.", wc_sounds$path)
wc_sounds$path[kp] <- gsub("\\.mp3$", ".wav", wc_sounds$path[kp])
wc_sounds$path[3] <- gsub("\\.mp3$", ".wav", wc_sounds$path[3])
wc_sounds
setwd("R")
save(wc_sounds, file = "sysdata.rda")

## check option
getOption("warcraft_mode")

## set max
warcraft_mode(Inf, 1.0)

## disable
warcraft_mode(FALSE)

## update git repo
add_to_git(
  "okay now .mp3 and .wav"
)
1
