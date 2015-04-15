library(shiny)
library(ape)
source("plotTree.R")

shinyServer(function(input, output) {

	tree <- eventReactive(input$drawButton, {
    	input$tree
  	})

	info <- eventReactive(input$drawButton, {
    	input$info
  	})

	heatmap <- eventReactive(input$drawButton, {
    	input$heatmap
  	})
  	
	cluster <- eventReactive(input$drawButton, {
    	input$clustering
  	})

	colour_nodes <- eventReactive(input$drawButton, {
    	input$colour_nodes
  	})
  	
  	tip_size <- eventReactive(input$drawButton, {
    	input$tip_size
  	})
  	
  	
  	# heatmap colours
  	start_col <- eventReactive(input$drawButton, {
    	input$start_col
  	})  	
  	middle_col <- eventReactive(input$drawButton, {
    	input$middle_col
  	}) 	
  	end_col <- eventReactive(input$drawButton, {
    	input$end_col
  	})
  	heatmap_breaks <- eventReactive(input$drawButton, {
    	input$heatmap_breaks
  	})
  	
  	
  output$Tree <- renderPlot({

	treeFile <- tree()
	infoFile <- info()
    heatmapFile <- heatmap()
    cluster <- cluster()
    colour_nodes <- colour_nodes()
    tip_size <- tip_size()
    start_col <- start_col()
    middle_col <- middle_col()
    end_col <- end_col()
    heatmap_breaks <- as.integer(heatmap_breaks())
    
    if (is.null(treeFile))
      return(NULL)
      
    doPlotTree <-function(){  
    
    	plotTree(tree=treeFile$datapath,infoFile=infoFile$datapath,
      		heatmapData=heatmapFile$datapath,cluster=cluster,colourNodesBy=colour_nodes,
      		tip.colour.cex=tip_size,heatmap.colours=colorRampPalette(c(start_col,middle_col,end_col),space="rgb")(heatmap_breaks)) 
    }
    
    

### SAVE FIGURE
      
      if(input$returnDownload){
if(input$type == 'PDF'){
                pdf("plot.pdf", width=as.numeric(input$w*3.94), height=as.numeric(input$h*3.94))
                doPlotTree()
                dev.off()

              output$pdflink <- downloadHandler(
            filename <- "myplot.pdf",
            content <- function(file) {
                file.copy("plot.pdf", file)
            })
} else if (input$type == "PNG"){
png("plot.png", width=as.numeric(input$w*3.94), height=as.numeric(input$h*3.94))
                doPlotTree()
                dev.off()
              output$pdflink <- downloadHandler(
            filename <- "myplot.png",
            content <- function(file) {
                file.copy("plot.png", file)
            })
} else {
stop(paste("Unexpected type returned:", input$type))
}
            }
            
### END SAVE FIGURE   

      doPlotTree()
      
  })
  
})