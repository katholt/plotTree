library(shiny)
library(ape)
source("plotTree.R")

### END R PLOTTING CODE

shinyServer(function(input, output) {

  output$Tree <- renderPlot({
    
    treeFile <- input$tree$datapath
    heatmapFile = NULL
    infoFile = NULL
    clusteringOption = NULL
    
    if (is.null(treeFile))
      return(NULL)
    
    if(input$chk_meta) {
      infoFile <- input$info$datapath
      if (input$chk_heatmap) {
        heatmapFile <- input$heatmap$datapath
      }
    }
    if (input$chk_heatmap) {
        heatmapFile <- input$heatmap$datapath
    }
    
    if(!is.null(heatmapFile)) {
      if(input$optionsPrompt) {
        if(input$clustering == "Cluster based on density") {
          clusteringOption = T
        } else 
          if (input$clustering == "Cluster according to tree") {
          clusteringOption = "square"
        }
      }
    }
    
      plotTree(treeFile, heatmapFile, infoFile, cluster=clusteringOption)
    })
})