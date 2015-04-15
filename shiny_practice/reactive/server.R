library(shiny)
library(ape)
source("plotTree.R")

shinyServer(function(input, output) {

	tree <- eventReactive(input$goButton, {
    	input$tree
  	})

	info <- eventReactive(input$goButton, {
    	input$info
  	})

	heatmap <- eventReactive(input$goButton, {
    	input$heatmap
  	})
  	
	cluster <- eventReactive(input$goButton, {
    	input$heat_cluster
  	})

	colour_nodes <- eventReactive(input$goButton, {
    	input$colour_nodes
  	})
  	
  	tip_size <- eventReactive(input$goButton, {
    	input$tip_size
  	})
  	
  output$Tree <- renderPlot({

	treeFile <- tree()
	infoFile <- info()
    heatmapFile <- heatmap()
    cluster <- cluster()
    colour_nodes <- colour_nodes()
    tip_size <- tip_size()
    
    if (is.null(treeFile))
      return(NULL)
    
      plotTree(tree=treeFile$datapath,infoFile=infoFile$datapath,
      		heatmapData=heatmapFile$datapath,cluster=cluster,colourNodesBy=colour_nodes,
      		tip.colour.cex=tip_size)
      
  })
  
})