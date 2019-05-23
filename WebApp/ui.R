#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#    https://rstudio.github.io/shinydashboard/get_started.html

setwd("./")

source("../Utility/utility.R")

environmentSettings()

source("../Utility/EfficientFrontier.R")
source("../Utility/EfficientFrontierPlot.R")

print(paste("Default UI working directory:",getwd()))

#Edit the main header of the dashboard
header <- dashboardHeader(
  title = "Efficient Frontier"
)


#Edit the body of the dashboard
body <- dashboardBody(
  tabItems(
    tabItem(
      tabName = "config",
      fluidRow(
        box(
          title = "Select Number of tickers", status = "primary", solidHeader = TRUE, collapsible = TRUE,
          "Choose a number of title that you want to have", br(), "Insert the names of the titles inside the input box",
          sliderInput("input_slider_tickerNumber", "Slider input:", 1, 5, 1),
          textInput("input_text_tickerName", "Ticker name:"),
          dateRangeInput("input_date_tickerDates", 
                         "Date range",
                         # Default data from past three months
                         start = Sys.Date() - 90, 
                         end = Sys.Date()),
          actionButton("button_tickerGenerate","Generate"),
          br(),
          verbatimTextOutput("output_stock_result"),
          br(),
          uiOutput("output_stock")
        ),
        box(
          title = "Choose Type of Investment", status = "primary", solidHeader = TRUE, collapsible = TRUE,
          "Select Long Only if you don't want use the constraints.", br(), "Select Constraints if you want to set the constraints",
          radioButtons("Type", "Type of Investment:",
                       c("Long Only" = "Long Only",
                         "Constraints" = "Constraints")
                       ),
          numericInput("Min", "Minimum Constraint", 0.00, min = 0.00, max = 0.50, step = 0.01),
          numericInput("Max", "Maximum Constraint", 0.00, min = 0.00, max = 0.50, step = 0.01)
          )
        )
      ),
    tabItem(
      tabName = "dashboard",
      fluidRow(
        box(
          title = "Eff Frontier Graph", status = "primary", solidHeader = TRUE, collapsible = TRUE
           ),
        box(
          title = "Bar Chart Minimum Variance Portfolio", status = "primary", solidHeader = TRUE, collapsible = TRUE
           ),
        box(
          title = "Tangency Portfolio", status = "primary", solidHeader = TRUE, collapsible = TRUE
           ),
        box(
          title = "Personal Investment & Simulation", status = "primary", solidHeader = TRUE, collapsible = TRUE
           ),
        actionButton("Download CSV", "CSV"),
        actionButton("Download CSV", "CSV"),
        actionButton("Download CSV", "CSV")
        )
      ),
    tabItem(
      tabName = "harrymarkovitz",
      fluidPage(titlePanel("Harry Markovitz"),
                selectInput("HarryMarkovitz", "", c("Select", "Harry Markowitz Wiki Ita", "Harry Markowitz Wiki Eng", "Portfolio Selection: Efficient Diversification of Investments")),
                mainPanel(
                  textOutput("Harry Markovitz")
                )
          )
        ),
    tabItem(
      tabName = "Efficientfrontier",
      fluidPage(titlePanel("Efficient Frontier"),
                selectInput("EfficientFrontier", "", c("Select")),
                mainPanel(
                  textOutput("Efficient Frontier")
                )
                )
           )
        )
)


#Edit the sidebar
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Configuration", tabName = "config",icon = icon("cogs"))
    , menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"))
    , menuItem("About Harry Markovitz", tabName = "harrymarkovitz", icon = icon("file"))
    , menuItem("About Efficient Frontier", tabName = "Efficientfrontier", icon = icon("file"))
    , menuItem("YAHOO FINANCE", icon = icon("file-code-o"), href = "https://it.finance.yahoo.com/")
    , menuItem("Contacts", icon= icon("file-code-o"),href = "")
  )
)


#Function for rendering the page
dashboardPage(
  skin = "blue",
  header,
  sidebar,
  body
)







