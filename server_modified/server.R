library(shiny)

shinyServer(

	function(input, output, session) {
		
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
				updateSelectInput(session, 'highlight_column', choices=info_cols)
				updateSelectInput(session, 'show_column', choices=info_cols)
			}
		)
	
	}
)