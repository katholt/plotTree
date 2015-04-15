library(shiny)
library(ape)

shinyServer(function(input, output) {
  output$Tree <- renderPlot({
    
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.

    inFile <- input$tree

    if (is.null(inFile))
      return(NULL)
    
      t<-read.tree(inFile$datapath)
      plot(t)
  })
})