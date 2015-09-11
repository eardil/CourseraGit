library(dplyr)
library(ggplot2)
library(leaflet)

hur <- read.csv(file = "hurdataLL.csv")




shinyServer(function(input, output){
  
  year <- input$year
  
  huranio <- filter(hur,Date>=year*10000,Date<(year+1)*10000)
  
  huranio <- huranio %>% mutate(DateNum = Hour/2300 + Date-min(Date))
  
  alpha <- lapply(unique(huranio$Name), function(x) data.frame(alpha =
    (huranio[huranio$Name==x,]$DateNum-min(huranio[huranio$Name==x,]$DateNum))/
      (max(huranio[huranio$Name==x,]$DateNum)-min(huranio[huranio$Name==x,]$DateNum)))) %>% rbind_all
  
  huranio <- cbind(huranio,alpha)
  
  # huranio$alpha <- (-1)*(1-huranio$alpha)
  
  pal <- colorFactor(palette = rainbow(length(levels(huranio$Name))),levels=levels(huranio$Name))
  
  m <- leaflet() %>% addTiles() %>% 
    addCircleMarkers(lng=-huranio$Lo,
                     lat=huranio$Lat,
                     stroke= F,
                     # fillOpacity = huranio$DateNum/max(huranio$DateNum),
                     fillColor=pal(huranio$Name),
                     fillOpacity = huranio$alpha,
                     radius = huranio$Maxwind/7,
                     popup=paste(
                       "Name: ",huranio$Name,"<br>",
                       "Date: ",huranio$Date,"<br>",
                       "Hour: ",huranio$Hour,"<br>")
    ) %>%
    addCircleMarkers(lng=-huranio$Lo,
                     lat=huranio$Lat,
                     stroke= T,
                     weight=1,
                     color="Black",
                     opacity=1,
                     fill=FALSE,
                     radius = huranio$Maxwind/7
    )
  
  output$mapa <- renderLeaflet(m)
  output$anio <- renderText(as.character(year))
})