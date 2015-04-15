library(shiny)
library(ape)
source("plotTree.R")

shinyServer(function(input, output) {
  output$Tree <- renderPlot({

    treeFile <- input$tree
    infoFile <- input$info
    heatmapFile <- input$heatmap
    
    if (is.null(treeFile))
      return(NULL)
    
      plotTree(tree=treeFile$datapath,infoFile=infoFile$datapath,heatmapData=heatmapFile$datapath)
      
  })
})