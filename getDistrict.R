library(dplyr)

con <- src_postgres(db = "frankfurt")

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