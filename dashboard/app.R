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
            checkboxInput('header', 'Header', TRUE),
            radioButtons('sep', 'Separator',c(Comma=',', Semicolon=';', Tab='\t'), 'Comma'),
            radioButtons('quote', 'Quote', c(None='', 'Double Quote'='"', 'Single Quote'="'"), 'Double Quote')
          ),
          mainPanel(
            tableOutput('contents'),
            tableOutput('colref')
          )
        )
      ),
      # Second tab content
      tabItem(tabName = "tabgraph",
              sidebarLayout(
                sidebarPanel(
                  sliderInput("bins",
                              "Number of bins:",
                              min = 1,
                              max = 50,
                              value = 30)
                ),
                
                # Show a plot of the generated distribution
                mainPanel(
                  plotOutput("distPlot")
                )
              )
      ),
      # Third tab content
      tabItem(tabName = "report",
              h2("Report Content")
      )
    )
  )
)
server <- function(input, output) {
  # these can only be done inside a reactive expression
    #input$searchText
    #input$searchButton
  output$contents <- renderTable({
    
    # input$file1 will be NULL initially. After the user selects and uploads a 
    # file, it will be a data frame with 'name', 'size', 'type', and 'datapath' 
    # columns. The 'datapath' column will contain the local filenames where the 
    # data can be found.
    
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
      read.csv(inFile$datapath, header=input$header, sep=input$sep, quote=input$quote)
  })
  output$distPlot <- renderPlot({
    
    # generate bins based on input$bins from ui.R
    x    <- faithful[, 2]
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
    
  })
}

shinyApp(ui, server)
