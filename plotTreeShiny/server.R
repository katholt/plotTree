library(shiny)
library(ape)
source("plotTree.R")

shinyServer( function(input, output, session) {

	# An event observer for changes to INFO CSV file
<<<<<<< HEAD
	observeEvent(input$infoFile, 
		{
			# read the CSV file and get the column names.
			# re-reading this file repeatedly is inefficient
			df = read.table(input$infoFile$datapath, header=TRUE, sep=',')
=======
	observeEvent(input$info_file, 
		{
			# read the CSV file and get the column names.
			# re-reading this file repeatedly is inefficient
			df = read.table(input$info_file$datapath, header=TRUE, sep=',')
>>>>>>> upstream/master
			# build a list of values, this is what is required by update methods
			info_cols = list()
			for (v in colnames(df)) {
				info_cols[v] = v
			}
			# update the two input widgets using the column names
<<<<<<< HEAD
			updateSelectInput(session, inputId='colour_tips_by', choices=c('NA',info_cols))
			updateSelectInput(session, inputId='print_column', choices=info_cols)
		}
	)
  
=======
			updateSelectInput(session, inputId='colour_tips_by', choices=c('(none)',info_cols[-1]))
			updateSelectInput(session, inputId='print_column', choices=c(info_cols[-1]))
			
			# switch on the meta data plotting option
			updateCheckboxInput(session, inputId='info_data', value=TRUE)
		}
	)
	
	# An event observer for changes to HEATMAP file
	observeEvent(input$heatmap, 
		{
			# switch on the heatmap plotting option
			updateCheckboxInput(session, inputId='chk_heatmap', value=TRUE)
		}
	)	
	
	# An event observer for changes to BAR DATA file
	observeEvent(input$barData, 
		{
			# switch on the heatmap plotting option
			updateCheckboxInput(session, inputId='chk_barplot', value=TRUE)
		}
	)	
	
	# An event observer for changes to BLOCKS file
	observeEvent(input$blockFile, 
		{
			# switch on the heatmap plotting option
			updateCheckboxInput(session, inputId='chk_blocks', value=TRUE)
		}
	)	

	# An event observer for changes to SNPs file
	observeEvent(input$snpFile, 
		{
			# switch on the heatmap plotting option
			updateCheckboxInput(session, inputId='chk_snps', value=TRUE)
		}
	)	
	  
>>>>>>> upstream/master
	output$Tree <- renderPlot({
  
		input$drawButton == 0

		### ALL VARIABLES PULLED FROM 'input' GO INSIDE HERE
		isolate ( {
		
<<<<<<< HEAD
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
      
      
=======
			l<-input$Layout
			t<-input$Tree
			i<-input$Info
			o<-input$Other
			d<-input$Data
		
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
			if (colour_tips_by == '(none)') {colour_tips_by <- NULL}
			ancestral <- input$ancestral
			pie_size <- input$pie_size
			legend <- input$legend
			legend_pos <- input$legend_pos
			print_column <- input$print_column
			print_metadata <- input$print_metadata
			if (!print_metadata) { print_column <- NA }
				
			# heatmap variables
			heatmapFile <- input$heatmap$datapath
			cluster <- input$clustering
			heatmapDecimalPlaces <- as.integer(input$heatmapDecimalPlaces)
			colLabelCex <- as.integer(input$colLabelCex)
			vlines_heatmap_col <-input$vlines_heatmap_col
			vlines_heatmap <- input$vlines_heatmap
			
#			heatColoursSpecify <- input$heatColoursSpecify
			
#			if (heatColoursSpecify) {
#				heatmap_colours <- input$heatmap_colour_vector
#			}
#			else {
				heatmap_colours <- colorRampPalette(c(input$start_col,input$middle_col,input$end_col),space="rgb")(as.integer(input$heatmap_breaks))
#			}
			
			# barplot variables
			barDataFile <- input$barData$datapath
			barDataCol <- input$barDataCol
			
			# block plot variables
			blockFile <- input$blockFile$datapath
			block_colour <- input$block_colour
			blwd <- input$blwd
			genome_size <- input$genome_size
			
			snpFile <- input$snpFile$datapath
			snp_colour <- input$snp_colour
			
			# Layout/spacing
			tree_width <- as.numeric(input$tree_width)
			info_width <- as.numeric(input$info_width)
			heatmap_width <- as.numeric(input$heatmap_width)
			bar_width <- as.numeric(input$bar_width)
			genome_width <- as.numeric(input$genome_width)
			main_height <- as.numeric(input$main_height)
			label_height <- as.numeric(input$label_height)
			edge_width <- as.numeric(input$edge_width)
	
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
			else { heatmapFile <- heatmapFile }
			
			if (!chk_barplot) { barDataFile <- NULL } 
			else { barDataFile <- barDataFile }
			
			if (!chk_blocks) { blockFile <- NULL } 
			else { blockFile <- blockFile }
			
			if (!chk_snps) { snpFile <- NULL } 
			else { snpFile <- snpFile }

>>>>>>> upstream/master
		}) # end isolate


		### PLOT THE TREE
	
		# main plotting function
		doPlotTree <-function() {  
	
			# underlying call to plotTree(), drawn to screen and to file
<<<<<<< HEAD
			plotTree(tree=treeFile,
				infoFile=infoFile, infoCols=print_column,
				colourNodesBy=colour_tips_by, tip.colour.cex=tip_size,
				heatmapData=heatmapFile, cluster=cluster, barData=barFile, barDataCol=barPlotColour,
				heatmap.colours=colorRampPalette(c(heat_start_col,heat_middle_col,heat_end_col),space="rgb")(heatmap_breaks)) 
=======
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
				barData=barDataFile, barDataCol=barDataCol,
				blockFile=blockFile, block_colour=block_colour, blwd=blwd,
				genome_size=genome_size,
				snpFile=snpFile, snp_colour=snp_colour,
				treeWidth=tree_width, infoWidth=info_width, dataWidth=heatmap_width,
				barDataWidth=bar_width, blockPlotWidth=genome_width, 
				mainHeight=main_height, labelHeight=label_height, edgeWidth=edge_width
				) 
>>>>>>> upstream/master
		}

		doPlotTree()
		
	}) # end render plot
	
<<<<<<< HEAD
}) # shinyServer
=======
}) # shinyServer
>>>>>>> upstream/master
