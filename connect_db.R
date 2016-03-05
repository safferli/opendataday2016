library(dplyr)

# swipes <- data.frame(user_id = sample(1:10, 10),
#                      address = sample(df$address, 10, replace = TRUE),
#                      swipes = sample(0:1, 10, replace = TRUE)
# )
#
# copy_to(db, swipes, temporary = FALSE)
user_id <- 9

db <- src_sqlite("merged.sqlite")

frankfurt <- dplyr::tbl(db, "frankfurt") %>%
  collect()

swipes <- tbl(db, "swipes") %>%
  filter(user_id == user_id) %>%
  collect() %>%
  left_join(frankfurt)

result <- swipes %>%
  group_by(district) %>%
  summarise(total = sum(swipes) / n()) %>%
  arrange(desc(total))
