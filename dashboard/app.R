#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(ggplot2)
library(DT)

ui <- dashboardPage(skin = "red",
  dashboardHeader(title = "AutoComplete", 
    # need to make this dynamic, but this is for demonstration purposes
    dropdownMenu(type = "messages", 
                 messageItem(from = "Sales Dept", message = "Sales are steady this month.", 
                             icon = icon("bar-chart"), time = "13:45")
    ),
    dropdownMenu(type = "notifications",
                 notificationItem(text = "5 new users today", icon("users")),
                 notificationItem(text = "12 items delivered", icon("truck"), status = "success")
    ),
    dropdownMenu(type = "tasks", badgeStatus = "success", 
                 taskItem(value = 90, color = "green", "Documentation"),
                 taskItem(value = 17, color = "aqua", "Project X"),
                 taskItem(value = 75, color = "yellow", "Server deployment"),
                 taskItem(value = 80, color = "red", "Overall project")
    )
  ),
  dashboardSidebar(
    sidebarSearchForm(textId = "searchText", buttonId = "searchButton", label = "Search..."),
    sidebarMenu(
      # These can be dynamically allocated as well
      menuItem("Data Import", tabName = "dataimport", icon = icon("database")),
      menuItem("Tables | Graphs", tabName = "tabgraph", icon = icon("bar-chart")),
      menuItem("Report", tabName = "report", icon = icon("file-text"))
    )
  ),
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "dataimport",
        pageWithSidebar(
          headerPanel(""),
          sidebarPanel(
            fileInput('file1', 'Choose CSV File', 
                      accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
            tags$hr(),
              checkboxGroupInput('show_vars', '', NULL, NULL)
          ),
          mainPanel(
            tableOutput('contents'),
            tabPanel('Data', DT::dataTableOutput('mytable1'))
          )
        )
      ),
      # Second tab content
      tabItem(tabName = "tabgraph",
              sidebarLayout(
                sidebarPanel(
                    checkboxGroupInput('x_vars', 'Data Import Needed', NULL, selected = NULL),
                    checkboxGroupInput('y_vars', '', NULL, selected = NULL)
                ),
                
                # Show a plot of the generated distribution
                mainPanel(
                  plotOutput("testPlot")
                )
              )
      ),
      # Third tab content
      tabItem(tabName = "report",
        h2("Report")
      )
    )
  )
)
server <- function(input, output, session) {
  # these can only be done inside a reactive expression
    #input$searchText
    #input$searchButton

  output$mytable1 <- DT::renderDataTable({
    inFile <- input$file1
    if (is.null(inFile))
      return(NULL)
    
    test <- read.csv(inFile$datapath)
    updateCheckboxGroupInput(session, "show_vars", label = "Columns in Data to Show:", choices = names(test), selected = input$show_vars)
    DT::datatable(test[, input$show_vars, drop = FALSE])
  })
  
  output$testPlot <- renderPlot({
    inFile <- input$file1
    if (is.null(inFile))
      return(NULL)
    
    test <- read.csv(inFile$datapath)
    updateCheckboxGroupInput(session, "x_vars", label = "X-axis:", choices = names(test), selected = input$x_vars)
    updateCheckboxGroupInput(session, "y_vars", label = "Y-axis:", choices = names(test), selected = input$y_vars)
    plot(test[,input$x_vars], test[,input$y_vars])
  })
}

shinyApp(ui, server)
