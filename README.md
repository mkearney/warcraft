## warcraft
The only R package you need.

## description
Plays audio from warcraft upon completion of every few R tasks.

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

## run setup function
warcraft::setup_warcraft(home)
```

## enter warcraft mode

``` r
## load package
library(warcraft)

## set to warcraft mode indefinitely
warcraft_mode(Inf)
```

## leave warcraft mode
``` r
## leave warcraft mode
warcraft_mode(Inf)
```

