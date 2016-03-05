library(ggplot2)
library(dplyr)
library(stringr)
library(maptools)
gpclibPermit()

ffm_gjson <- "http://offenedaten.frankfurt.de/dataset/85b38876-729c-4a78-910c-a52d5c6df8d2/resource/23d004a5-8a3b-4edf-bd70-4044263c9607/download/ffmstadtbezirkewahlen.geojson"
download.file(ffm_gjson, "ffmstadtbezirkewahlen.geojson")

orts <- geojsonio::geojson_read("ffmstadtbezirkewahlen.geojson", what = "sp")

orts@data$id <- rownames(orts@data)
df_orts <- fortify(orts, region = "id") %>%
  left_join(orts@data, by = "id")

df_coord <- data.frame(long = seq(min(df_orts$long),
                                  max(df_orts$long),
                                  length.out = 25),
                       lat = seq(min(df_orts$lat),
                                 max(df_orts$lat),
                                 length.out = 25)) %>%
  expand.grid()

coord_poly <- SpatialPoints(df_coord, proj4string = CRS(proj4string(orts)))
coord_in_poly <- over(coord_poly, orts)

p_map <- ggplot(df_orts, aes(lat, long)) +
  geom_polygon(aes(group = group, fill = STB_Name)) +
  geom_path(aes(group = group), color = "white") +
  coord_equal()

p_map +
  geom_point(data = df_coord[!is.na(coord_in_poly$id), ])
