library(shiny)
library(ape)
library(RLumShiny)
shinyUI(fluidPage(

	#titlePanel("Plot tree"),
	sidebarLayout(
		sidebarPanel(
		
			tabsetPanel(
			
				tabPanel("Tree",
		
					### UPLOAD TREE
					br(),
					fileInput('tree_file', 'Upload tree file (nwk)', multiple=F,
									accept=c('biotree/newick','.nwk', '.tree')),
			
					checkboxInput("label_tips", "Label tree tips?", value=FALSE),
					conditionalPanel(
						condition = "input.label_tips",
						textInput("tip_label_size", label = "Text size", value = "1"),
						textInput("offset", label = "Offset", value = "0")
					),
				
					textInput("tree_line_width", label = "Branch width", value = "1.5"),
					jscolorInput(inputId="branch_colour", label="Branch colour:", value="#000000", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
					br()
				), # finished tree tab	
				
				tabPanel("Info",
			
					### METADATA (info file)
					br(),
					fileInput('info_file', 'Upload metadata (CSV)'),
					checkboxInput('chk_info', 'Use metadata', value = FALSE),
					conditionalPanel(
						condition = "input.chk_info",
						checkboxInput('print_metadata', 'Print columns', value = FALSE),
						conditionalPanel(
							condition = "input.print_metadata",
							selectInput('print_column', 'Metadata columns to print:', c(''), multiple=TRUE)
						),
						"--------",
						selectInput('colour_tips_by', 'Colour tips by:', c('')),
						# options if colouring by tips
						conditionalPanel(
							condition = "input.colour_tips_by != '(none)'",
							sliderInput("tip_size", label = "Tip size", min = 0.1, max = 20, value = 0.5),
							### COLOUR PANELS
							checkboxInput("legend", "Legend for node colours?", value=TRUE),
							selectInput("legend_pos", label = "Position for legend", 
								choices = list( "bottomleft"="bottomleft", "bottomright"="bottomright",
												"top-left"="topleft", "topright"="topright")
							), 
							"--------",
							checkboxInput("ancestral", "Ancestral state reconstruction?", value=FALSE),
							sliderInput("pie_size", label = "Pie graph size", min = 0.1, max = 20, value = 0.5)
						)
					)
				),	# finished metadata tab	


				tabPanel("Data",
			
					### HEATMAP DATA
					br(),
					fileInput('heatmap_file', 'Upload heatmap file (CSV)', multiple = F, accept = c('text/csv', '.csv')),
					checkboxInput('chk_heatmap', 'Plot heatmap', value = FALSE),
					
					conditionalPanel(
						condition = "input.chk_heatmap", h4("Heatmap options"),
						selectInput("clustering", label = h5("Clustering:"), 
							choices = list("Select..."=F, "Cluster columns by values"=T, "Square matrix"="square"),
							selected = "Select"), 
						"--------",
			
						# OPTIONALLY DISPLAY COLOUR OPTIONS
						checkboxInput("heat_colours_prompt", "Change heatmap colour ramp", value=FALSE),
						conditionalPanel(
							condition = "input.heat_colours_prompt", 
							jscolorInput(inputId="start_col", label="Start colour:", value="FFFFFF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
							jscolorInput(inputId="middle_col", label="Middle colour:", value="FFF94D", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
							jscolorInput(inputId="end_col", label="End colour:", value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
							textInput("heatmap_breaks", label = "Breaks:", value = "100")
						),
	#					checkboxInput("heatColoursSpecify", "Specify heatmap colours manually", value=FALSE),
	#					conditionalPanel(
	#						condition = "input.heatColoursSpecify",
	#						textInput("heatmap_colour_vector", label = "R code (vector), e.g. rev(gray(seq(0,1,0.1)))", value = "")
	#					),
						"--------",
						textInput("heatmap_decimal_places", label = "Decimal places to show in heatmap legend:", value = "1"),
						textInput("col_label_cex", label = "Text size for column labels:", value = "0.75")
	#					textInput("vlines_heatmap", label = "y-coordinates for vertical lines (e.g. c(2,5)):", value = ""),
	#					jscolorInput(inputId="vlines_heatmap_col", label=h5("Colour for vertical lines:"), value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T)
					)
				), # finished heatmap options
			
				tabPanel("Other",
					tabsetPanel(
						tabPanel("Barplots",
							br(),
							# bar plots
							fileInput('bar_data_file', 'Upload data for bar plots (CSV)', multiple = F, accept = c('text/csv', '.csv')),
							checkboxInput('chk_barplot', 'Plot bar graphs', value = FALSE),
					
							conditionalPanel(
								condition = "input.chk_barplot", h5("Barplot options"),
								jscolorInput(inputId="bar_data_col", label="Colour for barplots:", value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T)
							)
						),
						
						tabPanel("Genome blocks",
							br(),
							# genome blocks
							fileInput('blocks_file', 'Upload genome block coordinates', multiple = F, accept = c('text/tab', '.txt')),
							checkboxInput('chk_blocks', 'Plot genome blocks', value = FALSE),
							
							conditionalPanel(
								condition = "input.chk_blocks", h5("Genome block plotting options"),
								textInput("genome_size", label = "Genome size (bp):", value = "5E6"),
								jscolorInput(inputId="blocks_colour", label="Colour for blocks:", value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
								sliderInput("blwd", label = "Block size", min = 0.1, max = 20, value = 5)
							)
						),
						
						tabPanel("SNPs",
							br(),
							# snps
							fileInput('snps_file', 'Upload SNP allele table (CSV)', multiple = F, accept = c('text/csv', '.csv')),
							checkboxInput('chk_snps', 'Plot SNPs', value = FALSE),
							
							conditionalPanel(
								condition = "input.chk_snps", h5("SNP plotting options"),
								textInput("genome_size", label = "Genome size (bp):", value = "5E6"), # make this linked to previous conditional 
								jscolorInput(inputId="snps_colour", label="Colour for SNPs:", value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T)
							)
						)
					) #finished other data subtabs
				), # finished other data tab
				
				tabPanel("Layout",
					br(),
					h5("Relative widths"),
					textInput("tree_width", label = "Tree", value = 10),
					textInput("info_width", label = "Info columns", value = 10),
					textInput("heatmap_width", label = "Heatmap", value = 30),
					textInput("bar_width", label = "Bar plots", value = 10),
					textInput("genome_width", label = "Genome data (blocks, SNPs)", value = 10),
					br(),
					h5("Relative heights"),
					textInput("main_height", label = "Main  panels", value = 100),
					textInput("label_height", label = "Heatmap labels", value = 10),
					br(),
					h5("Borders"),
					textInput("edge_width", label = "Border width/height", value = 1)
				)

			), # finish tabpanel
			
			### DRAW BUTTON
			br(),
			actionButton("draw_button", "Draw!")
			
			# ADD PRINT BUTTON HERE
			

		), # finished sidebarPanel

		mainPanel(
			plotOutput("Tree", height=800)
		)
		
	) # finished sidebarLayout
) # fluidPage

) # shinyUI

