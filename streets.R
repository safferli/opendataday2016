rm(list = ls()); gc(); gc()
# options(java.parameters = "-Xmx4096m")#8192
# options(java.parameters = "-XX:-UseConcMarkSweepGC")
# options(java.parameters = "-XX:-UseGCOverheadLimit")
options(bitmapType='cairo')
options(scipen = 999)
options(stringsAsFactors = FALSE)
#library(bbbi)
library(ggplot2)
#library(RODBC)
library(dplyr)
#library(tidyr)
library(data.table)
library(stringr)
library(reshape2)

# Define your workspace: "X:/xxx/"
wd <- "D:/github/opendataday2016/"
#wd <- "/home/csafferling/Documents/github/statistics101"
setwd(wd)

# http://offenedaten.frankfurt.de/dataset/strassenverzeichnis-der-stadt-frankfurt-am-main
# http://www.frankfurt.de/sixcms/detail.php?id=2911
ffm <- "http://www.offenedaten.frankfurt.de/dataset/7bd9de80-98de-45c2-99a8-497ce7b3c82c/resource/be5982fe-ed79-42f4-acdc-57ca4737fb7a/download/strassenverzeichnis2014.csv"
# data is encoded in windows from the city... 
dta <- read.csv(ffm, sep=";", stringsAsFactors = FALSE, fileEncoding = "WINDOWS-1258")

streets <- dta %>% 
  select(Straßenname, Folge, Hausnr...von., Hausnr...bis., Stadtteil.Name, Postleitzahl)

districts <- streets %>% 
  # group_by(Straßenname) %>% 
  # ungroup() %>% 
  group_by(Stadtteil.Name) %>% 
  tally() %>% 
  arrange(-n)

# write csv of streetnames to get started on the nodejs side
# encode in utf-8 because duh!
write.csv(unique(streets$Straßenname), file = "ffm-streetnames.csv", row.names = FALSE, fileEncoding = "UTF-8")

# clean up streets dataset (tolower, rename variables)
streets <- streets %>% 
    select(-Folge, -Postleitzahl) %>% 
    dplyr::rename(streetname = Straßenname, from = Hausnr...von., to = Hausnr...bis.,
                  district = Stadtteil.Name) %>% 
    mutate(streetname = tolower(streetname),
           district = tolower(district))

# get house numbers for missing values
ffm2 <- "http://www.offenedaten.frankfurt.de/dataset/9c902fd2-dd17-40cc-9fab-52c9c28aea3c/resource/064ae185-a5e6-4994-85c9-7403d1cf20a3/download/gprojekteopendatadatenamt62hausskoordinatendatensatze20164stand160304adressen.csv"
dta2 <- read.csv(ffm2, sep=";", stringsAsFactors = FALSE, header = FALSE, fileEncoding = "WINDOWS-1258")

# clean up
numbers <- dta2 %>%
    select(V10, V14) %>%
    mutate(V14 = tolower(V14)) %>% 
    dplyr::rename(housenr = V10, streetname = V14) %>% 
    mutate(housenr = tolower(housenr),
           housenr = gsub("([0-9]*)[a-z].*", "\\1", housenr), # strip out letters after house numbers
           housenr = gsub("^[a-z].*", "", housenr), # exclude house numbers starting with letter(s) 
           housenr2 = gsub("-.*", "\\1", housenr), # create variable with last number (if any)
           housenr3 = ifelse(housenr %like% "-", gsub("[0-9]*-(.)", "\\1", housenr), NA)) %>%  # create variable with first number (if any)
    select(-housenr) %>% 
    melt(id.vars = "streetname") %>%# convert to long format
    mutate(variable = as.character(variable)) %>% 
    filter(!is.na(value)) %>% 
    mutate(value = as.numeric(as.character(value))) %>%
    select(-variable)

# create df with streetname, from house number and to house number
fromto <- numbers %>% 
    group_by(streetname) %>% 
    summarise(from = min(value), 
              to = max(value))

# merge fromto with streets df to get district info
merged <- fromto %>%
    merge(data.frame(streetname = streets$streetname, 
                     district = streets$district), by = "streetname") %>%
    group_by(streetname) %>%
    mutate(N = length(district)) %>% 
    filter(N == 1) %>% 
    select(-N) %>% 
    data.frame(stringsAsFactors = FALSE) %>%
    mutate(district = as.character(district),
           from = as.numeric(from),
           to = as.numeric(to))

expand.addresses <- function(x) {
    data.frame(adress = paste(x$streetname, seq(from = x$from, to = x$to)), 
               district = x$district)
}

test2 <- merged %>% 
    filter(!is.na(to)) %>% 
    group_by(streetname) %>% 
    do(expand.addresses(.)) %>% 
    data.frame(stringsAsFactors = FALSE) %>% 
    select(-streetname)

