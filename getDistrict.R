library(dplyr)

con <- src_postgres(db = "frankfurt")

getDistrict <- function(userID) {
    df <- con %>%
        tbl("swipes") %>%
        filter(userID == userID) %>% 
        collect
    
    district <- con %>% 
        tbl("adresslist") %>% 
        collect
    
    fav <- df %>% 
        mutate(text = gsub(",*", "", text)) %>% 
        merge(district, by = "address") %>% 
        group_by(district) %>% 
        summarise(perc = (swipes == 1) / n()*100) %>%
        arrange(-perc) %>% 
        head(1) %>% 
        unlist
    
}