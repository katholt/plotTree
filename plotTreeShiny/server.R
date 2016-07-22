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

			updateSelectInput(session, inputId='colour_tips_by', choices=c('(none)',info_cols[-1]))
			updateSelectInput(session, inputId='select_columns', choices=c(info_cols[-1]))
			
			# switch on the meta data plotting option
			updateCheckboxInput(session, inputId='chk_data', value=TRUE)
		}
	)
	
	# An event observer for changes to HEATMAP file
	observeEvent(input$heatmap_file, 
		{
			# switch on the heatmap plotting option
			updateCheckboxInput(session, inputId='chk_heatmap', value=TRUE)
		}
	)	
	
	# An event observer for changes to BAR DATA file
	observeEvent(input$bar_data_file, 
		{
			# switch on the heatmap plotting option
			updateCheckboxInput(session, inputId='chk_barplot', value=TRUE)
		}
	)	
	
	# An event observer for changes to BLOCKS file
	observeEvent(input$blocks_file, 
		{
			# switch on the heatmap plotting option
			updateCheckboxInput(session, inputId='chk_blocks', value=TRUE)
		}
	)	

	# An event observer for changes to SNPs file
	observeEvent(input$snps_file, 
		{
			# switch on the heatmap plotting option
			updateCheckboxInput(session, inputId='chk_snps', value=TRUE)
		}
	)	
	  

	output$Tree <- renderPlot({
  
		input$draw_button == 0

		### ALL VARIABLES PULLED FROM 'input' GO INSIDE HERE
		isolate ( {
		
			l<-input$Layout
			t<-input$Tree
			i<-input$Metadata
			o<-input$Other
			d<-input$Heatmap
		
			tree_file <- input$tree_file$datapath
			
			# tree plotting options
			label_tips <- input$label_tips
			tree_line_width <- as.integer(input$tree_line_width)
			branch_colour <- input$branch_colour
			tip_label_size <- as.integer(input$tip_label_size)
			offset <- as.integer(input$offset)
			
			# metadata variables
			info_file <- input$info_file$datapath
			tip_size <- input$tip_size
			colour_tips_by <- input$colour_tips_by
			if (colour_tips_by == '(none)') {colour_tips_by <- NULL}
			ancestral <- input$ancestral
			pie_size <- input$pie_size
			legend <- input$legend
			legend_pos <- input$legend_pos
			select_columns <- input$select_columns
			chk_print_metadata <- input$chk_print_metadata
			if (!chk_print_metadata) { select_columns <- NA }
				
			# heatmap variables
			heatmap_file <- input$heatmap_file$datapath
			cluster <- input$clustering
			heatmap_decimal_places <- as.integer(input$heatmap_decimal_places)
			col_label_cex <- as.integer(input$col_label_cex)
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
			bar_data_file <- input$bar_data_file$datapath
			bar_data_col <- input$bar_data_col
			
			# block plot variables
			blocks_file <- input$blocks_file$datapath
			blocks_colour <- input$blocks_colour
			blwd <- input$blwd
			genome_size <- input$genome_size
			
			snps_file <- input$snps_file$datapath
			snps_colour <- input$snps_colour
			
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
			chk_info <- input$chk_info
			chk_barplot <- input$chk_barplot
			chk_blocks <- input$chk_blocks
			chk_snps <- input$chk_snps
	
			if (is.null(tree_file)) { return(NULL) }
	  
			if (!chk_info) { info_file <- NULL } 
			else { info_file <- info_file }
	
			if (!chk_heatmap) { heatmap_file <- NULL } 
			else { heatmap_file <- heatmap_file }
			
			if (!chk_barplot) { bar_data_file <- NULL } 
			else { bar_data_file <- bar_data_file }
			
			if (!chk_blocks) { blocks_file <- NULL } 
			else { blocks_file <- blocks_file }
			
			if (!chk_snps) { snps_file <- NULL } 
			else { snps_file <- snps_file }


		}) # end isolate


		### PLOT THE TREE
	
		# main plotting function
		doPlotTree <-function() {  
	
			# underlying call to plotTree(), drawn to screen and to file

			plotTree(tree=tree_file, 
				tip.labels=label_tips, tipLabelSize=tip_label_size, offset=offset,
				lwd=tree_line_width, edge.color=branch_colour,
				infoFile=info_file, infoCols=select_columns, 
				colourNodesBy=colour_tips_by, tip.colour.cex=tip_size, 
				ancestral.reconstruction=ancestral, pie.cex=pie_size, 
				legend=legend, legend.pos=legend_pos,
				heatmapData=heatmap_file, cluster=cluster,
				heatmap.colours=heatmap_colours,
				heatmapDecimalPlaces=heatmap_decimal_places, colLabelCex=col_label_cex,
				vlines.heatmap=vlines_heatmap, vlines.heatmap.col=vlines_heatmap_col,
				barData=bar_data_file, barDataCol=bar_data_col,
				blockFile=blocks_file, block_colour=blocks_colour, blwd=blwd,
				genome_size=genome_size,
				snpFile=snps_file, snp_colour=snps_colour,
				treeWidth=tree_width, infoWidth=info_width, dataWidth=heatmap_width,
				barDataWidth=bar_width, blockPlotWidth=genome_width, 
				mainHeight=main_height, labelHeight=label_height, edgeWidth=edge_width
				) 

		}

		doPlotTree()
		
	}) # end render plot
	
}) # shinyServer

