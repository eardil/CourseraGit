library(shiny)
library(leaflet)

# Define UI for dataset viewer application
bootstrapPage(
      # tabPanel('Resultados de búsqueda', dataTableOutput("search_hits")),
      tabPanel('Mapa', leafletOutput('mapa', width = 1000, height = 620),
               absolutePanel(top = 10, right = 10,
                             sliderInput("yearH", "Year", min(floor(hur$Date/10000)), max(floor(hur$Date/10000)),
                                         value = max(floor(hur$Date/10000)), step = 1
                                        ),
                             uiOutput("names")
                            )
    )
  )
