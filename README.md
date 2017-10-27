## warcraft
The only R package you *need*.

## description
Plays audio from warcraft upon completion of every few R tasks. Only
works on Mac's and linux-based machines.

## install
Install warcraft package from Github.

``` r
## install devtools if not already
if (!"devtools" %in% installed.packages()) {
  install.packages("devtools")
}

## install warcraft package
devtools::install_github("mkearney/warcraft")
```

## warcraft mode
Setup (installation of audio files and setting of R environment
variables) now happens at the time of installation/package load. Just
load the package to enter warcraft mode.

``` r
library(warcraft)
```

Or, crank it up to 11 by setting the max number of plays to `Inf`
(warcraft mode will last your entire R session) and the probability of
audio plays to 1.0 (audio will play during every top-level task)/

``` r
## max duration and frequency of audio plays
warcraft_mode(Inf, 1.0)
```

## leave warcraft mode
To leave warcraft mode, simply enter `FALSE` into the warcraft mode
function.

``` r
## leave warcraft mode
warcraft_mode(FALSE)
```
