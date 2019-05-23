#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


print(paste("Default Server working directory:",getwd()))



# Define server logic required to draw a histogram
function(input, output, session) {
  
  # create a reactive item
  nTickers <- reactive({
    
    if(input$button_tickerGenerate)
    {
      
      isolate( 
        box(
          title = "Tickers", status = "primary", solidHeader = TRUE,
          lapply(1:input$input_slider_tickerNumber, function(i)
          {
            textInput(paste("tInput",i), paste("Ticker", i,"Name"),"")
            # fluidRow(
            #   column(width = 10,offset = 1, wellPanel(
            #                       # h4(paste("No.", i,"Input Values")),
            #                       textInput(paste("tInput",i), "Ticker Name","")
            #                     # ,numericInput(paste("min",i),"Min",value=NA)
            #                     # ,numericInput(paste("max",i),"Max",value=NA)
            #                     # ,numericInput(paste("expect",i),"Expected Return",value=NA)
            #                     )
            #        )
            # )
          })
        )
      )
    }
  })
  
  #create output item for ticker insertion
  output$output_stock <- renderUI({
    
    if(input$input_slider_tickerNumber < 2)
    {
      output$output_stock_result <- renderText({"Please Input the Number of Assets Greater Than 2!"})
      return()
    }
    output$output_stock_result <- renderText({"Click Generate Button to Start!"})
    
    nTickers()  
    
  })
  
  
}


  
  
  