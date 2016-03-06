library(ggplot2)
library(dplyr)
library(stringr)
library(maptools)
gpclibPermit()

stadtteil <- "http://www.offenedaten.frankfurt.de/dataset/85b38876-729c-4a78-910c-a52d5c6df8d2/resource/84dff094-ab75-431f-8c64-39606672f1da/download/ffmstadtteilewahlen.geojson"

stadtbezirk <- "http://offenedaten.frankfurt.de/dataset/85b38876-729c-4a78-910c-a52d5c6df8d2/resource/23d004a5-8a3b-4edf-bd70-4044263c9607/download/ffmstadtbezirkewahlen.geojson"

download.file(stadtbezirk, "ffmstadtbezirkewahlen.geojson")
download.file(stadtteil, "ffmstadtteilewahlen.geojson")

get_data <- function(shape_filename) {
  df_shape <- geojsonio::geojson_read(shape_filename, what = "sp")

  df_shape@data$id <- rownames(df_shape@data)
  df_fortified <- fortify(df_shape, region = "id") %>%
    left_join(df_shape@data, by = "id")

  df_coord <- data.frame(long = seq(min(df_fortified$long),
                                    max(df_fortified$long),
                                    length.out = 25),
                         lat = seq(min(df_fortified$lat),
                                   max(df_fortified$lat),
                                   length.out = 25)) %>%
    expand.grid()

  coord_poly <- SpatialPoints(df_coord, proj4string = CRS(proj4string(df_shape)))
  coord_in_poly <- over(coord_poly, df_shape)
  df_coord <- df_coord[!is.na(coord_in_poly$id), ]
  results <- list(df_fortified, df_coord, df_shape)
  names(results) <- c("fortified", "coordinates", "shape")
  results
}

data_bezirk <- get_data("ffmstadtbezirkewahlen.geojson")
data_teil <- get_data("ffmstadtbezirkewahlen.geojson")

p_map <- ggplot(data_teil$fortified, aes(lat, long)) +
  geom_polygon(aes(group = group, fill = STB_Name)) +
  geom_path(aes(group = group), color = "white") +
  coord_equal()

p_map +
  geom_point(data = data_teil$coordinates)

