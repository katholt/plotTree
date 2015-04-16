library(shiny)
library(ape)
source("plotTree.R")

shinyServer(function(input, output, session) {

	tree <- input$tree
	info <- input$info_file
	heatmap <- input$heatmap
	cluster <- input$clustering
	colour_nodes <- input$colour_nodes
  	tip_size <- input$tip_size
  	
  	# heatmap colours
  	start_col <- input$start_col
  	middle_col <- input$middle_col
  	end_col <- input$end_col
  	heatmap_breaks <- as.integer(input$heatmap_breaks)
  	
  	highlight_column <- input$highlight_column
  	show_column <- input$show_column
  	
  	# track data types
  	chk_heatmap <- input$chk_heatmap
  	info_data <- input$info_data
  	  	
	# An event observer for changes to INFO CSV file
	observeEvent(input$info_file, 
		{
			# read the CSV file and get the column names.
			# re-reading this file repeatedly is inefficient
			df = read.table(input$info_file$datapath, header=TRUE, sep=',')
			
			# build a list of values, this is what is required by update methods
			info_cols = list()
			for (v in colnames(df)) {
				info_cols[v] = v
			}
			
			# update the two input widgets using the column names
			updateSelectInput(session, inputId='highlight_column', choices=info_cols)
			updateSelectInput(session, inputId='show_column', choices=info_cols)
		}
	)
    
    # we don't do anything if there's no tree file
    if (is.null(treeFile)) { return(NULL) }
    
    # switch off metadata plotting if the box is unchecked
    if (!info_data) { infoFile <- NULL } 
    else { infoFile <- info$datapath }
    
    # switch off heatmap plotting if the box is unchecked
    if (!chk_heatmap) { heatmapFile <- NULL } 
    else { heatmapFile <- heatmap$datapath }

	# plotTree wrapping (to allow calling for plotting to screen or file)
    doPlotTree <-function() {  
    	plotTree(tree=tree$datapath,
      		infoFile=infoFile,colourNodesBy=highlight_column,tip.colour.cex=tip_size,
      		infoCols=show_column,
      		heatmapData=heatmapFile,cluster=cluster,
      		heatmap.colours=colorRampPalette(c(start_col,middle_col,end_col),space="rgb")(heatmap_breaks)
      	) 
    }

	# PLOT THE TREE when button is pressed
	
	plot_tree <- F
	plot_tree <- eventReactive(input$drawButton, function() {
    	plot_tree <- T
	})
	
	output$Tree <- renderPlot({ 
		if (!plot_tree) { return (NULL) }
		doPlotTree()
		plot_tree <- F
	})
	
})
