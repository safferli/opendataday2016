library(ggmap)
library(dplyr)
library(stringr)
library(maptools)
gpclibPermit()

# Download shape file if it doesn't exist
if(!file.exists("ffmstadtteilewahlen.geojson")) {
  stadtteil <- paste0("http://www.offenedaten.frankfurt.de/dataset/",
                      "85b38876-729c-4a78-910c-a52d5c6df8d2/resource/",
                      "84dff094-ab75-431f-8c64-39606672f1da/download/",
                      "ffmstadtteilewahlen.geojson")

  download.file(stadtteil, "ffmstadtteilewahlen.geojson")
}

get_data <- function(shape_filename) {
  df_shape <- geojsonio::geojson_read(shape_filename, what = "sp")

  df_shape@data$id <- rownames(df_shape@data)
  df_fortified <- fortify(df_shape, region = "id") %>%
    left_join(df_shape@data, by = "id")

  results <- list(df_fortified, df_shape)
  names(results) <- c("fortified", "shape")
  results
}

# Get lists of dataframes with coordinates and shapes
data_teil <- get_data("ffmstadtteilewahlen.geojson")

# Read swipes
swipes <- read.csv("newswipes.csv", stringsAsFactors = FALSE)

# Make uniform district names
data_teil$fortified$STTLNAME <- data_teil$fortified$STTLNAME %>%
  as.character() %>%
  tolower()

swipes$district <- swipes$district %>%
  as.character() %>%
  tolower() %>%
  str_replace_all("sachsenhausen-n", "sachsenhausen-nord") %>%
  str_replace_all("sachsenhausen-s", "sachsenhausen-süd") %>%
  str_replace_all("gutleutviertel|bahnhofsviertel", "gutleut-/bahnhofsviertel")

# Calculate swipe shares
swipes_sum <- swipes %>%
  mutate(swipe = ifelse(swipe == "t", 1, -1)) %>%
  group_by(id, district) %>%
  summarise(swipe_share = mean(swipe)) %>%
  rename("user_id" = id) %>%
  ungroup()

# Join swipes data with shape data
data_teil$fortified <- left_join(data_teil$fortified, swipes_sum,
                                 by = c("STTLNAME" = "district"))

# Make map
bbox <- make_bbox(data_teil$fortified$long, data_teil$fortified$lat)
map_ffm <- get_map(bbox)

p_map <- ggmap(map_ffm) +
  geom_polygon(aes(y = lat, x = long, group = group, fill = swipe_share),
               alpha = 0.65,
               data = data_teil$fortified) +
  scale_fill_gradient(low = "red", high = "green") +
  theme_void() +
  theme(legend.position = "none")

add_district_text <- function(p_map, top_district) {

  df_top_district <- data_teil$fortified %>%
    filter(STTLNAME == top_district) %>%
    summarise(mid_lat = mean(c(max(lat), min(lat))),
              mid_long = mean(c(max(long), min(long))),
              district = unique(STTLNAME))

  p_map +
    geom_text(aes(x = mid_long, y = mid_lat, label = district),
              size = 2,
              data = df_top_district)
}

path_dir <- "opendataday2016/public/images/results/p_map.png"

ggsave(p_map, filename = path_dir)
