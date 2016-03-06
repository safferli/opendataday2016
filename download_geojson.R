# Download shape file if it doesn't exist
if(!file.exists("ffmstadtteilewahlen.geojson")) {
    stadtteil <- paste0("http://www.offenedaten.frankfurt.de/dataset/",
                        "85b38876-729c-4a78-910c-a52d5c6df8d2/resource/",
                        "84dff094-ab75-431f-8c64-39606672f1da/download/",
                        "ffmstadtteilewahlen.geojson")
    
    download.file(stadtteil, "ffmstadtteilewahlen.geojson")
}


