## load the first scriptorium emporium
lib(warcraft)

## build package
make_package(update = "patch", load_all = FALSE)

## check option
getOption("warcraft_mode")

## set max
warcraft_mode(Inf, 1.0)

## disable
warcraft_mode(FALSE)

## update git repo
add_to_git(
  "rm write lines duplicate to renv and added .wav ext to audio files"
)
1
