library(shiny)
library(ape)
source("plotTree.R")

### END R PLOTTING CODE

shinyServer(function(input, output) {
  output$Tree <- renderPlot({
    
    treeFile <- input$tree
    
    if (is.null(treeFile))
      return(NULL)
    
    if (input$chk_metadata) {
      infoFile <- input$info
    } else {
      infoFile <- NULL
    } 
    
    if (input$chk_heatmap) {
      heatmapFile <- input$heatmap
    } else {
      heatmapFile <- NULL
    }
    
    if (input$chk_barplot) {
      barplotFile <- input$barplot
    } else {
      barplotFile <- NULL
    }
    
    plotTree(tree=treeFile$datapath, heatmapData = heatmapFile$datapath, infoFile = infoFile$datapath,
             barData = barplotFile$datapath)
  })
})