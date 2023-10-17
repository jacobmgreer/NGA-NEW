options(
  readr.num_columns = 0, 
  readr.show_col_types = FALSE)

required <- c("purrr","plyr","tidyverse","jsonlite","textutils","tools","lubridate","magrittr","readr")
lapply(required, require, character.only = TRUE)

art_difference <- function(last, current) {
  if (!file.exists(paste0("output/changes/changes.", current, ".csv"))) {
    past <- 
      read_csv(paste0("output/onview/", last, ".csv")) %>% 
      rename(url.art = `url...2`) %>%
      select(id,title,attribution,roomTitle,url.art,imagepath)
    present <- 
      read_csv(paste0("output/onview/", current, ".csv")) %>% 
      rename(url.art = `url...2`) %>%
      select(id,title,attribution,roomTitle,url.art,imagepath)
    
    check <- 
      anti_join(past, present, by = c("id", "roomTitle")) %>%
      mutate(Status = "Removed") %>%
      bind_rows(.,
                anti_join(present, past, by = c("id", "roomTitle")) %>%
                  mutate(Status = "Added")) %>%
      mutate(
        attribution = HTMLdecode(attribution),
        title = HTMLdecode(title),
        month = format(ymd(current), "%B"),
        year = format(ymd(current), "%Y"),
        monthyear = format(ymd(current), "%B %Y"),
        datechange = format(ymd(current), "%B %d")) %>%
      arrange(Status, roomTitle, attribution, title) %>%
      select(-id)
    
    if(!empty(check)) {
      write.csv(check, file = paste0("output/changes/changes.",current,".csv"), row.names=FALSE)
    }
  }
}

input_list <- file_path_sans_ext(list.files("output/onview", pattern="*.csv", include.dirs = FALSE))
for (i in seq_along(input_list)) {
  if(i>1) {
    art_difference(input_list[i-1], input_list[i])}}

cols <-
  cols(
    title = col_character(),
    attribution = col_character(),
    roomTitle = col_character(),
    url.art = col_character(),
    imagepath = col_character(),
    Status = col_character(),
    month = col_character(),
    year = col_double(),
    monthyear = col_character(),
    datechange = col_character())

art_change <-
  list.files("output/changes", pattern="*.csv") %>%
  map(~ read_csv(file.path("output/changes", .), col_types = cols)) %>%
  reduce(suppressMessages(bind_rows)) %>%
  arrange(desc(year), desc(match(month, month.name)), desc(datechange), Status, roomTitle, attribution, title) %T>%
  write_json(., "output/art_change.json")

rm(i, required, art_difference, input_list, cols)
