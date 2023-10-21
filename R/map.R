required <- c("tidyverse", "magrittr", "sf", "geojsonsf")
lapply(required, require, character.only = TRUE)

geojson <- 
  geojson_sf("~/GitHub/NGA-NEW/R/mainfloor.geojson") %>%
  filter(!is.na(changeset)) %>%
  select(c())