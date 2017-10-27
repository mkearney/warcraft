## load the first scriptorium emporium
library(tfse)

## build package
make_package()

## check option
getOption("warcraft_mode")

## set max
warcraft_mode(Inf, 1.0)

## disable
warcraft_mode(FALSE)

## update git repo
add_to_git(
  "setup now takes place on install/package load. same with R environment variable. in general, everything works a lot better."
)
1
