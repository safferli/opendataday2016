library(geojsonio)
library(dplyr)
library(ggmap)

get_shapefile <- function(shape_filename) {
    df_shape <- geojsonio::geojson_read(shape_filename, what = "sp")
    
    df_shape@data$id <- rownames(df_shape@data)
    df_fortified <- fortify(df_shape, region = "id") %>%
        left_join(df_shape@data, by = "id")
    
    results <- list(df_fortified, df_shape)
    names(results) <- c("fortified", "shape")
    results
}