#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Libraries

library(shiny)
library(plotly)
library(rsconnect)

library(shinydashboard)
library(dygraphs)
library(tidyverse)
library(janitor)
library(dplyr)
library(ggplot2)
library(readr)
library(DT)
library(bslib)

library(dygraphs)
library(ggvis)



# Loading and Cleaning data

data_raw = read.csv("https://raw.githubusercontent.com/jnataky/Visual_Analytics/main/Final_project/New_York_City_Leading_Causes_of_Death.csv") %>% 
    janitor::clean_names() %>% 
    filter(
        race_ethnicity != "Not Stated/Unknown",
        race_ethnicity != "Other Race/ Ethnicity",
        leading_cause != "All Other Causes"
    ) %>% 
    mutate(
        deaths = as.numeric(deaths),
        death_rate = as.numeric(death_rate),
        age_adjusted_death_rate = as.numeric(age_adjusted_death_rate))


data <- data_raw %>% group_by(leading_cause, race_ethnicity, year) %>% dplyr::summarize(Total_Age_adjusted = sum(age_adjusted_death_rate))


# Define UI for application


ui <- dashboardPage(skin = "green", 
                    dashboardHeader(title = "DASHBOARD",titleWidth = 240,
                                    
                                    dropdownMenu(
                                        type = "notifications", 
                                        icon = icon("address-card"),
                                        badgeStatus = NULL,
                                        headerText = "Jered Ataky - Prof X"
                                        
                                    )
                                    
                                    
                                    
                    ),
                    
                    
                    dashboardSidebar(width = 240,
                                     
                                     sidebarMenu(
                                         menuItem('Overview',tabName = "Introduction",icon = icon("gear")),
                                         
                                         menuItem("Data Table",tabName = "Table",icon = icon("table")),
                                         menuItem("Death by Race and Sex",tabName = "DeathByRaceSex",icon = icon("chart-bar")),
                                         menuItem("Total Death Count by Gender",tabName = "DeathByGender",icon = icon("chart-bar")),
                                         menuItem("Total Death Count by Ethnicity",tabName = "DeathByrace",icon = icon("chart-bar")),
                                         menuItem("Leading Cause By Race",tabName = "LeadingCause",icon = icon("chart-bar")),
                                         menuItem("conclusion",tabName = "conclusion",icon = icon("comment-alt"))
                                     )),
                    
                    dashboardBody(
                        tabItems(
                            tabItem(tabName = 'Introduction',
                                    fluidRow(column(12, h2("NYC Leading Cause of Death"))),
                                    fluidRow(img(src = "images.png",height = 480, width = 785), h1('Introduction')),
                                    br(),
                                    fluidRow(column(12,p("What are the top causes of death in New York City? How long can we expect to live? Are we gaining or losing ground against our most life-threatening public health crises? Death statistics can provide insights into many facets of modern life. Mortality data answers critical questions like these, helping us understand how many New Yorkers are dying and – importantly – why. The data I'll work with explores the leading causes of death in New York City. I have pulled the data from the NYC Open Data site to explore this area of inquiry.
This data has 7 different variables: year, sex, ethnicity, cause of death, count of deaths, death rate, and Age adjusted death rate"))),
                                    fluidRow(h1('Data Source'),
                                             br(),
                                             fluidRow(column(12,p("Cause of death is derived from the NYC death certificate which is issued for every death that occurs in New York City. The Data is provided by Department of Health and Mental Hygiene (DOHMH):"), a("NYC-Open-DATA", href="https://data.cityofnewyork.us/Health/New-York-City-Leading-Causes-of-Death/jb7j-dtam"))
                                             ))),
                            tabItem(tabName= "Table", 
                                    fluidRow(
                                        box(DT::dataTableOutput("deathTable")))),
                            tabItem(tabName="DeathByRaceSex",
                                    fluidRow(h1('Death By Race and Sex')),
                                    column(8, plotOutput("deathPlot")),
                                    column(4, selectInput(inputId = "year",
                                                          label = "Select Year:",
                                                          choices = c("2007",
                                                                      "2008",
                                                                      "2009",
                                                                      "2010",
                                                                      "2011",
                                                                      "2012",
                                                                      "2013",
                                                                      "2014")),
                                           radioButtons(inputId = "sex",
                                                        label = "Sex:",
                                                        choices = c(
                                                            "Female" = "F",
                                                            "Male" = "M"
                                                        )),
                                           radioButtons(inputId = "race",
                                                        label = "Race/Ethnicity:",
                                                        choices = unique(data_raw$race_ethnicity))
                                    ),),
                            
                            tabItem(tabName = "DeathByGender",
                                    fluidRow(h1('Total Death Count By Gender')),
                                    column(8, plotOutput("sexplot")),
                                    #column(4, h1("Nothing Here")),
                                    fluidRow(
                                        infoBox("Female", 442, icon = icon("female"), fill = TRUE),
                                        infoBox("Male", 443, icon = icon("male"), fill = TRUE),
                                        infoBox("Total", 885, icon = icon("restroom"), fill = TRUE)
                                    )
                            ),
                            
                            tabItem(tabName = "DeathByrace",
                                    
                                    fluidRow(
                                        column(width = 8,
                                               box(
                                                   title = "Total Death Count by Ethnicity", width = NULL, status = "primary",
                                                   plotOutput("raceplot")
                                               ),
                                               box(
                                                   status = "warning", width = NULL,
                                                   p('There was more death reported in the Non-Hispanic White population, following by Non-Hispanic Black and Hispanic population. The Asian and Pacific Islanders had the least amount of death toll recorded each year. However, death reported in the Non-Hispanic White population had decreased each year from 2007 to 2014, whereas other ethnic groups seemed to stay about the consistent amongst both genders.')
                                               )
                                               
                                        ),
                                        
                                        column(width = 4,
                                               box(
                                                   status = "warning", width = NULL,
                                                   infoBox("Asian and Pacific Islander", 221, icon = icon("users"), width = NULL)
                                                   
                                               ),
                                               
                                               box(
                                                   status = "warning", width = NULL,
                                                   infoBox("Hispanic", 221, icon = icon("users"), width = NULL),
                                               ),
                                               
                                               box(
                                                   status = "warning", width = NULL,
                                                   infoBox("Non-Hispanic Black", 60, icon = icon("users"), width = NULL)
                                                   
                                               ),
                                               
                                               box(
                                                   status = "warning", width = NULL,
                                                   infoBox("Non-Hispanic White", 61, icon = icon("users"), width = NULL)
                                                   
                                               ),
                                               
                                               box(
                                                   status = "warning", width = NULL,
                                                   infoBox("White Non-Hispanic", 160, icon = icon("users"), width = NULL)
                                                   
                                               )
                                               
                                        ),
                                        
                                        
                                    )
                            ),
                            
                            tabItem(tabName = "LeadingCause",
                                    fluidRow(h1('Total Age Adjusted Death Count By Leading Cause By Race in NYC')),
                                    fluidRow(plotOutput("causeplot")),
                                    fluidRow(column(12, 
                                                    sliderInput("slider1", h3("Years"),
                                                                min = 2007, max = 2017, value = 1, 
                                                                sep = "", width = 500,
                                                                animate=TRUE)
                                    )),
                                    fluidRow(column(12, p("The Cause of Death chart suggests that two of the leading causes were much more common than the others, and they were heart disease and cancer.")))
                                    
                                    
                                    
                            ),
                            
                            
                            
                            
                            
                            tabItem(tabName = "conclusion",
                                    
                                    fluidRow(h1('Conclusion')),
                                    fluidRow(p("Causes for death change depending on age. For children between ages 1 to 9 and adolescent and young adults between the ages of 10 and 24 years old, lethal accidents claimed 31.5% of those who died. For those between 45 and 64, cancer kills 30.5%, and it's in this age group that heart disease, for the first time, becomes the second-leading cause of death. At 65, heart disease becomes the leading cause of death for New Yorkers, therefore it is critical to continue to promote healthy living and early disease intervention"))
                                    
                                    
                            )
                        )
                        
                        
                        
                        
                        
                    )
                    
                    
                    
)



# Define server logic required 


server = function(input, output) {
    
    output$deathTable = 
        DT::renderDataTable({
            data_raw
            # DT::datatable(selections()[,c("leading_cause", "deaths", "death_rate", "age_adjusted_death_rate")],
            #              colnames = c("Leading Cause of Death", "Number of Deaths", "Death Rate", "Age-Adjusted Death Rate"),
            #             options = list(order = list(2, 'des')),
            #            rownames = FALSE
            #)
            
        })
    
    ######## Death by year by sex
    
    selections = reactive({
        req(input$year)
        req(input$sex)
        req(input$race)
        filter(data_raw, year == input$year) %>%
            filter(sex %in% input$sex) %>%
            filter(race_ethnicity %in% input$race)})
    
    output$deathPlot = renderPlot({
        ggplot(data = selections(), aes(x = reorder(leading_cause, -deaths), y = deaths)) +
            geom_bar(stat = 'identity', color = 'white', fill = '#865ca8') +
            labs(
                
                x = "Causes",
                y = "Number of Deaths"
            ) +
            theme(axis.text.x = element_text(angle = 45, hjust=1))
    })
    
    output$sexplot = renderPlot(({
        
        data_raw %>% group_by(year,sex) %>% summarise(Total = sum(as.numeric(deaths)), .groups = 'keep') %>%
            ggplot(aes(year,Total)) +  geom_bar(aes(fill = sex), position ="dodge",stat = "identity") + ylab('Total Death')
    }))
    
    output$raceplot = renderPlot(({
        
        data_raw %>% group_by(year,race_ethnicity) %>% summarise(Total = sum(as.numeric(deaths)), .groups = 'keep') %>%
            ggplot(aes(year,Total)) +  geom_bar(aes(fill = race_ethnicity), position ="dodge",stat = "identity") + ylab('Total Death')
    }))
    
    
    selections2 = reactive({
        req(input$slider1)
        filter(data, year == input$slider1)
    })
    
    output$causeplot = renderPlot({
        
        ggplot(data = selections2(), aes(fill=leading_cause, y=Total_Age_adjusted, x=race_ethnicity)) + guides(fill=guide_legend(ncol=3)) + theme(legend.position="bottom")+
            geom_bar(position="dodge", stat="identity")
        
    })
    
    
}



# Run the application 
shinyApp(ui = ui, server = server)
