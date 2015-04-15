library(shiny)

shinyUI(
	fluidPage(
		titlePanel('tester'), 
		sidebarLayout(
			sidebarPanel(
			
				fileInput('treeFile', 'Tree'),
			
				# Test widgets for selecting INFO CSV file and
				# display column selection options.
				checkboxInput("info_data", "Info Data"),
				conditionalPanel(
					condition = "input.info_data",
					fileInput('info_file', 'Info CSV'),
					selectInput('show_column', 'Show Columns', c(''), multiple=TRUE),
					selectInput('highlight_column', 'Highlight By', c(''))
				),

				actionButton("update", "Update")
			),
				  
			mainPanel()
		)
	)
)
