# getHeatmap.R
options(stringsAsFactors = FALSE)
library(ggmap)
library(dplyr)
library(stringr)
library(maptools)
library(geojsonio)
gpclibPermit()
source("get_shapefile.R")
source("getDistrict.R")
con <- src_postgres(db = "frankfurt")

#* @get /heatmap
getDisctrictMap <- function(userID) {
    # Get lists of dataframes with coordinates and shapes
    data_teil <- get_shapefile("ffmstadtteilewahlen.geojson")
    
    # get data from database
    swipes <- con %>% 
        tbl("swipes") %>% 
        filter(id == userID) %>% 
        collect
    
    getDistrict <- function(userID) {
        # get swipes for specified user
        data <- con %>%
            tbl("swipes") %>%
            filter(id == userID) %>%
            collect
        
        # compute swipe percentage and pick the district with the highest right swipe 
        # percentage (randomly, in case there are several districts with max(perc)) 
        data %>%  
            mutate(swipe = ifelse(swipe == "f", 0, 1)) %>% 
            group_by(district) %>% 
            summarise(perc = sum(swipe, na.rm = TRUE) / length(swipe)*100) %>%
            arrange(-perc) %>% 
            filter(perc == max(perc)) %>%
            sample_n(1) %>% 
            unlist(use.names = FALSE)
        
    }
    
    top_district <- getDistrict(userID)[1]
    
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
    
    
    df_top_district <- data_teil$fortified %>%
        filter(STTLNAME == top_district) %>%
        summarise(mid_lat = mean(c(max(lat), min(lat))),
                  mid_long = mean(c(max(long), min(long))),
                  district = unique(STTLNAME))
    
    p_map <- ggmap(map_ffm) +
        geom_polygon(aes(y = lat, x = long, group = group, fill = swipe_share),
                     alpha = 0.65,
                     data = data_teil$fortified) +
        scale_fill_gradient(low = "red", high = "green") +
        theme_void() +
        theme(legend.position = "none") +
        geom_text(aes(x = mid_long, y = mid_lat, label = district), size = 2,
                  data = df_top_district)
    
    path_dir <- paste0("public/images/results/", userID, ".png")
    
    ggsave(p_map, filename = path_dir)
    
} 
