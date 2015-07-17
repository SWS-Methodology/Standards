library(shiny)
library(shinydashboard)

ui <- dashboardPage(
    
    dashboardHeader(title = "Food Balance Sheets"),
    
    dashboardSidebar(disable = TRUE),
    
    dashboardBody(
        fluidRow(
            column(width = 4
#                 numericInput(inputId = "numericInput",
#                              label = "",
#                              value = .05, min = 0, max = 1/3),
#                 sliderInput(inputId = "sliderInput",
#                             label = "",
#                             value = 30, min = 0, max = 200, step = 1)
            ),
            column(width = 8, 
                tabBox(width = 12,
                    tabPanel(title = "Production"),
                    tabPanel(title = "Imports"),
                    tabPanel(title = "Exports")
                ),
                infoBoxOutput("test", width = 3)
            )
        )
    )
)
