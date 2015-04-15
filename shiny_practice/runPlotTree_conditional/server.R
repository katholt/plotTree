library(shiny)
library(ape)
source("plotTree.R")

shinyServer(function(input, output) {
  output$Tree <- renderPlot({

    treeFile <- input$tree
    infoFile <- input$info
    heatmapFile <- input$heatmap
    cluster <- input$heat_cluster
    colour_nodes <- input$colour_nodes
    tip_size <- input$tip_size
    
    if (is.null(treeFile))
      return(NULL)
    
      plotTree(tree=treeFile$datapath,infoFile=infoFile$datapath,
      		heatmapData=heatmapFile$datapath,cluster=cluster,colourNodesBy=colour_nodes,
      		tip.colour.cex=tip_size)
      
  })
})