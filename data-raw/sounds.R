## Builds R/sysdata.rda (the wc_sounds catalog).
## Run from the package root: source("data-raw/sounds.R")

war2 <- function(x) {
  paste0("http://www.thanatosrealms.com/war2/sounds/orcs/", x, ".wav")
}

wc_sounds <- rbind(
  data.frame(
    name = "ready",
    category = "start",
    url = war2("peon/ready"),
    stringsAsFactors = FALSE
  ),
  data.frame(
    name = "jobsdone",
    category = "done",
    url = "https://www.myinstants.com/media/sounds/jobs-done_1.mp3",
    stringsAsFactors = FALSE
  ),
  data.frame(
    name = "workwork",
    category = "task",
    url = "https://www.myinstants.com/media/sounds/wc3-peon-says-work-work-only-.mp3",
    stringsAsFactors = FALSE
  ),
  data.frame(
    name = paste0("acknowledge", 1:4),
    category = "task",
    url = war2(paste0("basic-orc-voices/acknowledge", 1:4)),
    stringsAsFactors = FALSE
  ),
  data.frame(
    name = paste0("selected", 1:6),
    category = "task",
    url = war2(paste0("basic-orc-voices/selected", 1:6)),
    stringsAsFactors = FALSE
  ),
  data.frame(
    name = paste0("annoyed", 1:7),
    category = "error",
    url = war2(paste0("basic-orc-voices/annoyed", 1:7)),
    stringsAsFactors = FALSE
  ),
  data.frame(
    name = "death",
    category = "error",
    url = war2("basic-orc-voices/death"),
    stringsAsFactors = FALSE
  )
)

## hidden files so the cache dir stays out of the way in ~/
wc_sounds$path <- paste0(
  ".", wc_sounds$name, ".warcraft.", tools::file_ext(wc_sounds$url)
)
wc_sounds <- wc_sounds[c("name", "category", "path", "url")]
row.names(wc_sounds) <- NULL

save(wc_sounds, file = "R/sysdata.rda", version = 2)
