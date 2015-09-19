library(shiny)
library(leaflet)

# Define UI for dataset viewer application
bootstrapPage(
      # tabPanel('Resultados de búsqueda', dataTableOutput("search_hits")),
      
      tabPanel('Mapa', leafletOutput('mapa',height=800),
               HTML('<style>.rChart {width: 100%; height: 500px}</style>'),
               absolutePanel(top = 10, right = 10,
                             sliderInput("yearH", "Year", 1955, 2014,
                                         value = 2014, step = 1
                                        ),
                             uiOutput("names")
                            )
    )
  )
