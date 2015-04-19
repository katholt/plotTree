library(shiny)
library(ape)
library(RLumShiny)
shinyUI(fluidPage(
	titlePanel("Plot tree"),
	sidebarLayout(
		sidebarPanel(
		
			### UPLOAD TREE
			fileInput('tree', 'Upload tree file (nwk)', multiple=F,
							accept=c('biotree/newick','.nwk', '.tree')),
			
			### METADATA (info file)
			checkboxInput("chk_info", "Metadata"),
			
			# OPTIONS TO DISPLAY IF METADATA CHECKED
			conditionalPanel(
				condition = "input.chk_info",
				fileInput('infoFile', 'Upload metadata (CSV)'),
				selectInput('print_column', 'Metadata columns to print:', c(''), multiple=TRUE),
				selectInput('colour_tips_by', 'Colour tips by:', c('')),
				sliderInput("tip_size", label = "Tip size", min = 0.1, max = 20, value = 0.5)
			),	# finished metadata options	

			### HEATMAP DATA
			checkboxInput("chk_heatmap", "Heatmap data", value=FALSE),
			
			# OPTIONS TO DISPLAY IF HEATMAP CHECKED
			conditionalPanel(
				condition = "input.chk_heatmap",

				fileInput('heatmapFile', 'Upload heatmap file (CSV)', multiple = F, accept = c('text/csv', '.csv')),
				selectInput("clustering", label = h5("Clustering:"), 
					choices = list("Select..."=F, "Cluster columns by values"=T, "Square matrix"="square"),
					selected = "Select"), 
				
				# OPTIONALLY DISPLAY COLOUR OPTIONS
				checkboxInput("heatColoursPrompt", "Change heatmap colours", value=FALSE),
				conditionalPanel(
					condition = "input.heatColoursPrompt", h5("Heatmap colour ramp:"),
					jscolorInput(inputId="start_col", label="Start colour:", value="FFFFFF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
					jscolorInput(inputId="middle_col", label="Middle colour:", value="FFF94D", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
					jscolorInput(inputId="end_col", label="End colour:", value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
					textInput("heatmap_breaks", label = "Breaks:", value = "100")
				)
			), # finished heatmap options
      
      # BAR PLOT DATA
      checkboxInput("chk_barPlot", "Bar plot data", value=FALSE),
      
      # OPTIONS TO DISPLAY IF BAR PLOT CHECKED
      conditionalPanel(
        condition="input.chk_barPlot",
        fileInput("barFile", "Upload bar plot data file (CSV)", multiple=F, accept=c("text/csv", ".csv")),
      selectInput("barPlotColour", label=h5("Bar plot colour:"),
                  choices=list("Black"=1, "Red"=2, "Green"=3, "Blue"=4, "Cyan"=5, "Magenta"=6,
                               "Yellow"=7, "Gray"=8), selected=1)),

			### DRAW BUTTON
			actionButton("drawButton", "Draw!")
			
		), # finished sidebarPanel

		mainPanel(
			plotOutput("Tree", height=800)
		)
		
	) # finished sidebarLayout
) # fluidPage
) # shinyUI
