rm(list = ls()); gc(); gc()
# options(java.parameters = "-Xmx4096m")#8192
# options(java.parameters = "-XX:-UseConcMarkSweepGC")
# options(java.parameters = "-XX:-UseGCOverheadLimit")
options(bitmapType='cairo')
options(scipen = 999)
#library(bbbi)
library(ggplot2)
#library(RODBC)
library(dplyr)
#library(tidyr)
#library(data.table)

# Define your workspace: "X:/xxx/"
wd <- "D:/github/opendataday2016/"
#wd <- "/home/csafferling/Documents/github/statistics101"
setwd(wd)

# http://offenedaten.frankfurt.de/dataset/strassenverzeichnis-der-stadt-frankfurt-am-main
# http://www.frankfurt.de/sixcms/detail.php?id=2911

ffm <- "http://www.offenedaten.frankfurt.de/dataset/7bd9de80-98de-45c2-99a8-497ce7b3c82c/resource/be5982fe-ed79-42f4-acdc-57ca4737fb7a/download/strassenverzeichnis2014.csv"

dta <- read.csv(ffm, sep=";", stringsAsFactors = FALSE)

streets <- dta %>% 
  select(Straßenname, Folge, Hausnr...von., Hausnr...bis., Stadtteil.Name, Postleitzahl)

districts <- streets %>% 
  # group_by(Straßenname) %>% 
  # ungroup() %>% 
  group_by(Stadtteil.Name) %>% 
  tally() %>% 
  arrange(-n)
