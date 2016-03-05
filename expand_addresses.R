load("ffm_housenr.RData")

merged$streetname <- str_trim(merged$streetname)
merged$streetname <- as.character(merged$streetname)
merged$district <- str_trim(merged$district)
merged$from <- as.numeric(merged$from)
merged$to <- as.numeric(merged$to)
merged <- merged[complete.cases(merged), ]

merged <- merged %>%
  group_by(streetname, district) %>%
  do(data.frame(full_name = paste(.$streetname, .$from:.$to)))
