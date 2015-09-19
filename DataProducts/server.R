library(dplyr)
library(ggplot2)
library(leaflet)

hur <- read.csv(file = "hurdataLL.csv")




shinyServer(function(input, output){
  huranioTemp <- reactive({
    filter(hur,floor(Date/10000)==input$yearH)
    # hur[floor(hur$Date/10000)==input$yearH & (hur$Name == input$nameH | "ALL" == input$nameH),]
  })
  
#   huranioTemp <- reactive({
#     huranioTemp1()[huranioTemp1()$Name == input$nameH | "ALL"==input$nameH]
#   })
  
  
  output$mapa <- renderLeaflet({leaflet(hur) %>% addTiles() %>%
      fitBounds(~min(-filter(hur,floor(Date/10000)==2014)$Lo),
                ~min(filter(hur,floor(Date/10000)==2014)$Lat),
                ~max(-filter(hur,floor(Date/10000)==2014)$Lo),
                ~max(filter(hur,floor(Date/10000)==2014)$Lat))
    })
  
  observe({
    
    huranio <- huranioTemp() %>% mutate(DateNum = Hour/2300 + Date-min(Date))
    
    alpha <- lapply(unique(huranio$Name), function(x) data.frame(alpha =
               (huranio[huranio$Name==x,]$DateNum-min(huranio[huranio$Name==x,]$DateNum))/
                (max(huranio[huranio$Name==x,]$DateNum)-min(huranio[huranio$Name==x,]$DateNum)))) %>% rbind_all
    
    huranio <- cbind(huranio,alpha)
    pal <- colorFactor(palette = rainbow(length(levels(huranio$Name))),levels=levels(huranio$Name))
    leafletProxy("mapa") %>% 
      clearMarkers() %>%
      addCircleMarkers(lng=-huranio$Lo,
                     lat=huranio$Lat,
                     stroke= F,
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
    
    })
  
  observe({output$names <- renderUI({
    selectInput(inputId = "nameH",label = "Hurricane Name",choices = as.list(c("ALL",as.character(unique(huranioTemp()$Name)))),
                selected = "ALL")
  })})
  
  output$anio <- renderText(paste("Hurricanes from ",as.character(year)))
  
})