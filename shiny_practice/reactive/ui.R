library(shiny)
library(ape)
library(RLumShiny)

shinyUI(fluidPage(
  titlePanel("Plot tree"),
  sidebarLayout(
    sidebarPanel(
 
      fileInput('tree', 'Choose tree file', multiple=F,
                accept=c('biotree/newick', 
								 '.nwk', '.tree')),
 
      fileInput('info', 'Choose info file', multiple=F,
                accept=c('text/csv', 
								 '.csv')),
								 
	textInput("colour_nodes", label = h4("Colour nodes by"), value = "Enter variable name"),

	sliderInput("tip_size", label = h4("Tip size"), min = 0.1, 
      		  max = 20, value = 0.5),
						
						
	### HEATMAP DATA
	
      checkboxInput("chk_heatmap", "Heatmap file", value=TRUE),
      
      conditionalPanel(
        condition = "input.chk_heatmap", "Heatmap",
        fileInput('heatmap', 'Choose heatmap file', multiple = F, accept = c('text/csv', '.csv')),
        
	# HEATMAP OPTIONS
	checkboxInput("optionsPrompt", "Check box if you wish to not use the default values.", value=FALSE),
	conditionalPanel(
	  condition = "input.optionsPrompt", 
	  selectInput("clustering", label = "Columns clustering:", 
				  choices = list("Select"=F, "Cluster based on density"=T, "Cluster according to tree"="square"), selected = "Select"), 
				  "Note: You can only cluster according to tree if your rows are equal to your tree tips. I.e. if you're viewing the dataset against itself.",

		 
	 jscolorInput(inputId="start_col", label="Start colour", value="FFFFFF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
     jscolorInput(inputId="middle_col", label="Middle colour", value="FFF94D", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
     jscolorInput(inputId="end_col", label="End colour", value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
	 textInput("heatmap_breaks", label = "Breaks", value = "100")

				  )

	),
 
 actionButton("drawButton", "Draw!"),
 
 checkboxInput('returnDownload', 'Download figure?', FALSE),
 
	conditionalPanel(
            condition = "input.returnDownload == true",
			radioButtons("type", "Download type:",
             c(#"SVG" = "SVG",
               "PDF" = "PDF",
               "PNG" = "PNG")),            sliderInput(inputId="w", label = "width (A4=210mm):", min=60, max=600, value=210, width='80%', ticks=F),
            sliderInput(inputId="h", label = "height (A4=297mm):", min=60, max=600, value=297, width='80%', ticks=F),
            br(),
            downloadLink('pdflink')    
    )
    ),
    mainPanel(
      plotOutput("Tree", height=800))
    )
)
)