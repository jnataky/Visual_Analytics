#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)
library(rsconnect)

# Import the Data

cdc_data<- read.csv("https://raw.githubusercontent.com/charleyferrari/CUNY_DATA_608/master/module3/data/cleaned-cdc-mortality-1999-2010-2.csv")


# Define UI for application

ui <- fluidPage(
    
    # use a gradient in background
    setBackgroundColor(
        color = c("#F7FBFF", "#2171B5"),
        gradient = "linear",
        direction = "bottom"
    ),
    
    titlePanel("Crude Mortality Rate Across US States Vs National Average"), 
    sidebarPanel(
        selectInput("select1", label = strong("State"), 
                    choices = levels(as.factor(cdc_data$State)), 
                    selected = 1),
        
        selectInput("select2", label = strong("Cause of Death"), 
                    choices = levels(as.factor(cdc_data$ICD.Chapter)), 
                    selected = 1),
        
        width = "auto"
    ),
    
    mainPanel(
        plotOutput("distPlot")
    )
)


# Define server logic required 

server <- function(input, output) {
    output$distPlot <- renderPlot({
        cdc_data %>% 
            group_by(Year, ICD.Chapter) %>%
            mutate(N_Population = sum(Population),
                   N_Count = sum(Deaths), 
                   N_Crude_Rate = 10^5*(N_Count/N_Population)) %>% 
            group_by(Year, ICD.Chapter, State) %>%
            mutate(S_Count=sum(Deaths),
                   S_Crude_Rate=10^5*(S_Count/Population)) %>%
            
            select(ICD.Chapter, State, Year, N_Crude_Rate, S_Crude_Rate) %>% 
            filter(ICD.Chapter == input$select2, State == input$select1) %>% 
            
            ggplot() +
            geom_bar(aes(x = Year, weight = S_Crude_Rate), fill = "#ff0000") +
            labs(x = "State", y = "Crude Mortality Rate") +
            
            geom_line(aes(x = Year, y = N_Crude_Rate, linetype = "National Average"), col = "blue", lwd = 1) +
            scale_linetype(name = NULL) +
            theme_minimal()
    }
    )
}


# Run the application 
shinyApp(ui = ui, server = server)