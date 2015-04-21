library(shiny)
library(ape)
source("plotTree.R")

shinyServer( function(input, output, session) {

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
			updateSelectInput(session, inputId='colour_tips_by', choices=c('',info_cols))
			updateSelectInput(session, inputId='print_column', choices=info_cols)
		}
	)
  
	output$Tree <- renderPlot({
  
		input$drawButton == 0

		### ALL VARIABLES PULLED FROM 'input' GO INSIDE HERE
		isolate ( {
		
			treeFile <- input$tree$datapath
			
			# tree plotting options
			label_tips <- input$label_tips
			tree_line_width <- as.integer(input$tree_line_width)
			branch_colour <- input$branch_colour
			tipLabelSize <- as.integer(input$tipLabelSize)
			offset <- as.integer(input$offset)
			
			# metadata variables
			infoFile <- input$info_file$datapath
			tip_size <- input$tip_size
			colour_tips_by <- input$colour_tips_by
			if (colour_tips_by == '') {colour_tips_by <- NA}
			ancestral <- input$ancestral
			pie_size <- input$pie_size
			legend <- input$legend
			legend_pos <- input$legend_pos
			print_column <- input$print_column
				
			# heatmap variables
			heatmap <- input$heatmap
			cluster <- input$clustering
			heatmapDecimalPlaces <- as.integer(input$heatmapDecimalPlaces)
			colLabelCex <- as.integer(input$colLabelCex)
			vlines_heatmap_col <-input$vlines_heatmap_col
			vlines_heatmap <- input$vlines_heatmap
			
			heatColoursSpecify <- input$heatColoursSpecify
			
			if (heatColoursSpecify) {
				heatmap_colours <- input$heatmap_colour_vector
			}
			else {
				heatmap_colours <- colorRampPalette(c(input$start_col,input$middle_col,input$end_col),space="rgb")(as.integer(input$heatmap_breaks))
			}
			
			# barplot variables
			barData <- input$barData$datapath
			barDataCol <- input$barDataCol
			
			# block plot variables
			blockFile <- input$blockFile$datapath
			block_colour <- input$block_colour
			blwd <- input$blwd
			genome_size <- input$genome_size
			
			snpFile <- input$snpFile
			snp_colour <- input$snp_colour
	
			# TRACK DATA TYPES TO PLOT
			chk_heatmap <- input$chk_heatmap
			info_data <- input$info_data
			chk_barplot <- input$chk_barplot
			chk_blocks <- input$chk_blocks
			chk_snps <- input$chk_snps
	
			if (is.null(treeFile)) { return(NULL) }
	  
			if (!info_data) { infoFile <- NULL } 
			else { infoFile <- infoFile }
	
			if (!chk_heatmap) { heatmapFile <- NULL } 
			else { heatmapFile <- heatmap$datapath }
			
			if (!chk_barplot) { barData <- NULL } 
			else { barData <- barData }
			
			if (!chk_blocks) { blockFile <- NULL } 
			else { blockFile <- blockFile }
			
			if (!chk_snps) { snpFile <- NULL } 
			else { snpFile <- snpFile }

		}) # end isolate


		### PLOT THE TREE
	
		# main plotting function
		doPlotTree <-function() {  
	
			# underlying call to plotTree(), drawn to screen and to file
			plotTree(tree=treeFile, 
				tip.labels=label_tips, tipLabelSize=tipLabelSize, offset=offset,
				lwd=tree_line_width, edge.color=branch_colour,
				infoFile=infoFile, infoCols=print_column, 
				colourNodesBy=colour_tips_by, tip.colour.cex=tip_size, 
				ancestral.reconstruction=ancestral, pie.cex=pie_size, 
				legend=legend, legend.pos=legend_pos,
				heatmapData=heatmapFile, cluster=cluster,
				heatmap.colours=heatmap_colours,
				heatmapDecimalPlaces=heatmapDecimalPlaces, colLabelCex=colLabelCex,
				vlines.heatmap=vlines_heatmap, vlines.heatmap.col=vlines_heatmap_col,
				barData=barData, barDataCol=barDataCol,
				blockFile=blockFile, block_colour=block_colour, blwd=blwd,
				genome_size=genome_size,
				snpFile=snpFile, snp_colour=snp_colour) 
		}

		doPlotTree()
		
	}) # end render plot
	
}) # shinyServer