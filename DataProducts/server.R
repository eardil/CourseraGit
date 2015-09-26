library(dplyr)
library(ggplot2)
library(leaflet)
library(markdown)

hur <- read.csv(file = "hurdataLL.csv")
hur <- filter(hur,Date>=19550000) %>% mutate(Color=Name,alpha=0)
colH <- hur$Name




shinyServer(function(input, output){
  huranioTemp <- reactive({
    filter(hur,floor(Date/10000)==input$yearH)
    # hur[floor(hur$Date/10000)==input$yearH & (hur$Name == input$nameH | "ALL" == input$nameH),]
  })
  

  colH <- reactive({
    if(!is.null(input$nameH)) {
    if(!is.null(input$nameH) && input$nameH == "ALL") {aaa<-huranioTemp()$Name}
    else {aaa<-huranioTemp()$Name
          aaa[aaa!=input$nameH]<-NA}
    return(aaa)}
  })
  

  output$mapa <- renderLeaflet({leaflet(hur) %>% addTiles() %>%
      fitBounds(~min(-filter(hur,floor(Date/10000)==2014)$Lo),
                ~min(filter(hur,floor(Date/10000)==2014)$Lat),
                ~max(-filter(hur,floor(Date/10000)==2014)$Lo),
                ~max(filter(hur,floor(Date/10000)==2014)$Lat))
    })
  
  observe({
    
    huranio <- huranioTemp() %>% mutate(DateNum = Hour/2300 + Date-min(Date))
    huranio$Color <- colH()

    huranio$alpha <- lapply(unique(huranio$Name), function(x) 
            # if(!is.null(input$nameH) && (input$nameH == "ALL" || input$nameH == x)) 
              {data.frame(alpha =
               (huranio[huranio$Name==x,]$DateNum-min(huranio[huranio$Name==x,]$DateNum))/
                (max(huranio[huranio$Name==x,]$DateNum)-min(huranio[huranio$Name==x,]$DateNum)))}
            # else{data.frame(alpha=as.data.frame(matrix(0,ncol=1,nrow = sum(huranio$Name==x))))}
            ) %>% rbind_all
    
    pal <- colorFactor(palette = rainbow(length(levels(huranio$Name))),levels=levels(huranio$Name))
    leafletProxy("mapa") %>% 
      clearMarkers() %>%
      addCircleMarkers(lng=-huranio$Lo,
                     lat=huranio$Lat,
                     stroke= F,
                     fillColor=pal(huranio$Color),
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
  
#   observe({output$tabla <- renderDataTable({
#     as.data.frame(colH())
#   })})
  
  # output$anio <- renderText(paste("Hurricanes from ",as.character(year)))
  
})