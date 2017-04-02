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
