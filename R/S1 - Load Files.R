options(
  readr.num_columns = 0, 
  readr.show_types = FALSE)

required <- c("purrr", "plyr", "tidyverse", "jsonlite", "textutils", "tools", "lubridate", "magrittr", "readr")
lapply(required, require, character.only = TRUE)

flat_art <- function(data) {
  data %>%
    pull(onViewSettings) %>% 
    map_df(~ map_chr(.x, ~ replace(.x, is.null(.x), NA))) %>%
    bind_cols(data %>% select(., -onViewSettings), .) %>%
    dplyr::rename(url = `url...2`)}

list <- 
  setdiff(
    file_path_sans_ext(list.files("~/GitHub/An-Artsy-Cat-Burgles/nightlies/onview", pattern="*.json", include.dirs = FALSE)),
    file_path_sans_ext(list.files("output/onview", pattern="*.csv", include.dirs = FALSE))
  )

for (i in list) {
  nightly <- 
    flat_art(do.call("rbind.fill", 
                     lapply(fromJSON(paste0("~/GitHub/An-Artsy-Cat-Burgles/nightlies/onview/",i,".json"))["results"],
                            as.data.frame)))
  nightly <- apply(nightly,2,as.character)
  
  write.csv(nightly, paste0("output/onview/", i, ".csv"), row.names = FALSE) 
  
  #if(!exists(paste0("i", i))) {assign(paste0("i", i), nightly)}
}

rm(i, required, flat_art, list, nightly)
