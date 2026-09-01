<!-- README.md is generated from README.Rmd. Please edit that file -->

# warcraft <img src="man/figures/logo.png" width="160px" align="right" />

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

An R package you truly *need*.

## description

Plays audio from warcraft while you work. It is a joke, but a useful one:
tasks that cost real CPU time get a **"job's done"**, tasks that fail get an
**annoyed orc**, and everything else is random peon chatter. So the noise
actually tells you something.

Requires `afplay` (macOS) or one of `play` (sox), `paplay`, or `aplay`
(linux).

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

Audio files are downloaded once, on first load, into `~/.warcraft`.


``` r
library(warcraft)

## enter warcraft mode
warcraft_mode()
```

By default you get a random clip on roughly one task in ten, a "job's done"
for any task costing 5+ seconds of CPU time, and an error clip whenever a
task fails.

Tune it:


``` r
## quiet assistant: say nothing unless a task took 30+ seconds or blew up
warcraft_mode(Inf, p = 0, min_time = 30)

## max duration and frequency of audio plays
warcraft_mode(Inf, p = 1.0)

## no error sounds, purely random
warcraft_mode(errors = FALSE, min_time = Inf)
```

## leave warcraft mode

To leave warcraft mode, simply enter `FALSE` into the warcraft mode
function.


``` r
## leave warcraft mode
warcraft_mode(FALSE)

## or just silence it for a while
warcraft_mute()
warcraft_mute(FALSE)
```

## one-off announcements

`warcraft_when_done()` times an expression exactly and announces the result,
whether or not warcraft mode is on. It works in scripts too.


``` r
fit <- warcraft_when_done(lm(mpg ~ ., mtcars))

## only speak up if the block ran longer than a minute
warcraft_when_done({
  download_everything()
  fit_the_big_model()
}, min_time = 60)
```

Or play something yourself:


``` r
warcraft_play("done")
warcraft_play("workwork")
```

## what's going on


``` r
warcraft_status()
#> warcraft mode : ON
#> sounds        : 21/21 cached in /Users/mwk/.warcraft
#> player        : found
#> muted         : FALSE
#> plays left    : 497
#> probability   : 0.1
#> min_time      : 5 CPU seconds
#> error sounds  : TRUE

warcraft_sounds()
```
