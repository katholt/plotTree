library(shiny)
library(ape)
source("plotTree.R")

shinyServer( function(input, output, session) {

	# An event observer for changes to INFO CSV file
	observeEvent(input$infoFile, 
		{
			# read the CSV file and get the column names.
			# re-reading this file repeatedly is inefficient
			df = read.table(input$infoFile$datapath, header=TRUE, sep=',')
			# build a list of values, this is what is required by update methods
			info_cols = list()
			for (v in colnames(df)) {
				info_cols[v] = v
			}
			# update the two input widgets using the column names
			updateSelectInput(session, inputId='colour_tips_by', choices=c('NA',info_cols))
			updateSelectInput(session, inputId='print_column', choices=info_cols)
		}
	)
  
	output$Tree <- renderPlot({
  
		input$drawButton == 0

		### ALL VARIABLES PULLED FROM 'input' GO INSIDE HERE
		isolate ( {
		
			treeFile <- input$tree$datapath
			
			# metadata variables
			infoFile <- input$infoFile
			tip_size <- input$tip_size
			colour_tips_by <- input$colour_tips_by
			print_column <- input$print_column
				
			# heatmap variables
			heatmapFile <- input$heatmapFile
			cluster <- input$clustering
			heat_start_col <- input$start_col
			heat_middle_col <- input$middle_col
			heat_end_col <- input$end_col
			heatmap_breaks <- as.integer(input$heatmap_breaks)
      
      # bar plot variables
      barFile <- input$barFile
			barPlotColour <- input$barPlotColour
	
	
			# TRACK DATA TYPES TO PLOT
			chk_info <- input$chk_info
      chk_heatmap <- input$chk_heatmap
			chk_barPlot <- input$chk_barPlot     
	
			if (is.null(treeFile))
			  return(NULL)
	  
			if (!chk_info) { infoFile <- NULL } 
			else { infoFile <- infoFile$datapath }
	
			if (!chk_heatmap) { heatmapFile <- NULL } 
			else { heatmapFile <- heatmapFile$datapath }

			if (!chk_barPlot) { barFile <- NULL } 
			else { barFile <- barFile$datapath }
      
      
		}) # end isolate


		### PLOT THE TREE
	
		# main plotting function
		doPlotTree <-function() {  
	
			# underlying call to plotTree(), drawn to screen and to file
			plotTree(tree=treeFile,
				infoFile=infoFile, infoCols=print_column,
				colourNodesBy=colour_tips_by, tip.colour.cex=tip_size,
				heatmapData=heatmapFile, cluster=cluster, barData=barFile, barDataCol=barPlotColour,
				heatmap.colours=colorRampPalette(c(heat_start_col,heat_middle_col,heat_end_col),space="rgb")(heatmap_breaks)) 
		}

		doPlotTree()
		
	}) # end render plot
	
}) # shinyServer
