library(shiny)
library(ape)

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
								 
	fileInput('heatmap', 'Choose heatmap file', multiple=F,
                accept=c('text/csv', 
								 '.csv')),
								 
	checkboxInput("heat_cluster", label = "Cluster heatmap", value = TRUE),
 
 actionButton("goButton", "Go!"),
 
 checkboxInput('returnDownload', 'download?', FALSE),
 
	conditionalPanel(
            condition = "input.returnDownload == true",
            sliderInput(inputId="w", label = "width (A4=210mm):", min=60, max=600, value=210, width='80%', ticks=F),
            sliderInput(inputId="h", label = "height (A4=297mm):", min=60, max=600, value=297, width='80%', ticks=F),
radioButtons("type", "Download type:",
             c(#"SVG" = "SVG",
               "PDF" = "PDF",
               "PNG" = "PNG")),
            br(),
            downloadLink('pdflink')
            
    )
    ),
    mainPanel(
      plotOutput("Tree", height=800))
    )
)
)