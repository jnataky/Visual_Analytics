#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

cdc_data <- read.csv("https://raw.githubusercontent.com/charleyferrari/CUNY_DATA_608/master/module3/data/cleaned-cdc-mortality-1999-2010-2.csv")

library(shiny)
library(plotly)
library(rsconnect)
library(shinyWidgets)

# Define UI for application that draws a bar graph


ui <- fluidPage(
    
    # use a gradient in background
    setBackgroundColor(
        color = c("#F7FBFF", "#2171B5"),
        gradient = "linear",
        direction = "bottom"
    ),
    
    # Application title
    titlePanel(div("Cause of Crude Mortality Rate Across US States", style = "color: #ff0000")), 
    
    
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        selectInput("select", label = h3("Causes of Death"), 
                    choices = cdc_data$ICD.Chapter, 
                    selected = 1,
                    width = '100%'),
        
        # Show a plot of the generated distribution
        
        mainPanel(
            plotOutput("distPlot")
        )
    )
)

# Define server logic required to draw a bar graph

server <- function(input, output) {
    output$distPlot <- renderPlot({
        ggplot(cdc_data[cdc_data$ICD.Chapter == input$select,] , aes(x = reorder(State, Crude.Rate), y = Crude.Rate)) +
            labs(x = "State", y = "Crude Mortality Rate") +  
            geom_bar(stat = "identity", fill = "#ff0000") +
            coord_flip() +
            theme_minimal()
    }, width = 'auto', height = 'auto')
}

# Run the application
shinyApp(ui = ui, server = server)