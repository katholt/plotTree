library(shiny)
library(ape)
library(RLumShiny)
shinyUI(fluidPage(
	#titlePanel("Plot tree"),
	sidebarLayout(
		sidebarPanel(
		
			### UPLOAD TREE
			fileInput('tree', 'Upload tree file (nwk)', multiple=F,
							accept=c('biotree/newick','.nwk', '.tree')),
			
			checkboxInput("treeOptions", h5("Change tree plotting options"), value=FALSE),
			conditionalPanel(
				condition = "input.treeOptions",
				checkboxInput("label_tips", "Label tree tips?", value=FALSE),
				
				conditionalPanel(
					condition = "input.label_tips",
					textInput("tipLabelSize", label = "Text size", value = "1"),
					textInput("offset", label = "Offset", value = "0")
				),
				
				textInput("tree_line_width", label = "Branch width", value = "1.5"),
				jscolorInput(inputId="branch_colour", label="Branch colour:", value="#000000", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T)
			),	# finished tree options	
				
			### METADATA (info file)
			checkboxInput("info_data", h5("Add Metadata")),
			
			# OPTIONS TO DISPLAY IF METADATA CHECKED
			conditionalPanel(
				condition = "input.info_data",
				fileInput('info_file', 'Upload metadata (CSV)'),
				selectInput('print_column', 'Metadata columns to print:', c(''), multiple=TRUE),
				selectInput('colour_tips_by', 'Colour tips by:', c('')),
				# options if colouring by tips
				conditionalPanel(
					condition = "input.colour_tips_by",
					sliderInput("tip_size", label = "Tip size", min = 0.1, max = 20, value = 0.5),
					### COLOUR PANELS
					checkboxInput("legend", "Legend for node colours?", value=TRUE),
					selectInput("legend_pos", label = "Position for legend", 
						choices = list( "bottomleft"="bottomleft", "bottomright"="bottomright",
										"top-left"="topleft", "topright"="topright")
					), 
					checkboxInput("ancestral", "Ancestral state reconstruction?", value=FALSE),
					sliderInput("pie_size", label = "Pie graph size", min = 0.1, max = 20, value = 0.5)
				)
			),	# finished metadata options	

			### HEATMAP DATA
			checkboxInput("chk_heatmap", h5("Add Heatmap Data"), value=FALSE),
			
			# OPTIONS TO DISPLAY IF HEATMAP CHECKED
			conditionalPanel(
				condition = "input.chk_heatmap",
				fileInput('heatmap', 'Upload heatmap file (CSV)', multiple = F, accept = c('text/csv', '.csv')),
				selectInput("clustering", label = h5("Clustering:"), 
					choices = list("Select..."=F, "Cluster columns by values"=T, "Square matrix"="square"),
					selected = "Select"), 
				
				# OPTIONALLY DISPLAY COLOUR OPTIONS
				checkboxInput("heatColoursPrompt", "Change heatmap colour ramp", value=FALSE),
				conditionalPanel(
					condition = "input.heatColoursPrompt", h5("Heatmap colour ramp"),
					jscolorInput(inputId="start_col", label="Start colour:", value="FFFFFF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
					jscolorInput(inputId="middle_col", label="Middle colour:", value="FFF94D", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
					jscolorInput(inputId="end_col", label="End colour:", value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
					textInput("heatmap_breaks", label = "Breaks:", value = "100")
				),
				checkboxInput("heatColoursSpecify", "Specify heatmap colours manually", value=FALSE),
				conditionalPanel(
					condition = "input.heatColoursSpecify", h5("Vector to use heatmap colours"),
					textInput("heatmap_colour_vector", label = "R code", value = "rev(gray(seq(0,1,0.1)))")
				),
				textInput("heatmapDecimalPlaces", label = "Decimal places to show in heatmap legend:", value = "1"),
				textInput("colLabelCex", label = "Text size for column labels:", value = "0.75"),
				textInput("vlines_heatmap", label = "y-coordinates for vertical lines:", value = "c(2,5)"),
				jscolorInput(inputId="vlines_heatmap_col", label="Colour for vertical lines:", value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T)				
				
				
			), # finished heatmap options
			
			### BAR PLOT DATA
			checkboxInput("chk_barplot", h5("Add Barplots"), value=FALSE),
			
			# OPTIONS TO DISPLAY IF HEATMAP CHECKED
			conditionalPanel(
				condition = "input.chk_barplot",
				fileInput('barData', 'Upload data for bar plots (CSV)', multiple = F, accept = c('text/csv', '.csv')),
				jscolorInput(inputId="barDataCol", label="Colour for barplots:", value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T)
			), # finished bar plot options
			
			### GENOME BLOCKS DATA
			checkboxInput("chk_blocks", h5("Plot genome blocks"), value=FALSE),
			
			# OPTIONS TO DISPLAY IF HEATMAP CHECKED
			conditionalPanel(
				condition = "input.chk_blocks",
				fileInput('blockFile', 'Upload genome block coordinates', multiple = F, accept = c('text/tab', '.txt')),
				textInput("genome_size", label = "Genome size (bp):", value = "5E6"),
				jscolorInput(inputId="block_colour", label="Colour for blocks:", value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
				sliderInput("blwd", label = "Block size", min = 0.1, max = 20, value = 5)
			), # finished block plot options
			
			### SNP DATA
			checkboxInput("chk_snps", h5("Plot SNP loci"), value=FALSE),
			
			# OPTIONS TO DISPLAY IF HEATMAP CHECKED
			conditionalPanel(
				condition = "input.chk_snps",
				fileInput('snpFile', 'Upload SNP allele table (CSV)', multiple = F, accept = c('text/csv', '.csv')),
				textInput("genome_size", label = "Genome size (bp):", value = "5E6"), # make this linked to previous conditional 
				jscolorInput(inputId="snp_colour", label="Colour for SNPs:", value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T)
			), # finished block plot options			

			### DRAW BUTTON
			actionButton("drawButton", "Draw!")
			
		), # finished sidebarPanel

		mainPanel(
			plotOutput("Tree", height=800)
		)
		
	) # finished sidebarLayout
) # fluidPage
) # shinyUI