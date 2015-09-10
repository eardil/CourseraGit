library(dplyr)
library(ggplot2)
library(leaflet)

hur <- read.csv(file = "hurdataLL.csv")

hur2014 <- filter(hur,Date>=20140000)

pal <- colorFactor(palette = "Blues",domain=levels(hur2014$Hurclass))

m <- leaflet() %>% addTiles() %>% 
  addCircleMarkers(lng=-hur2014$Lo,
                   lat=hur2014$Lat,
                   popup=hur2014$Name,
                   stroke= FALSE,
                   fillOpacity = 0.8,
                   color=~pal(hur2014$Hurclass)
                   )

m
