library(shiny)
library(ape)

shinyUI(fluidPage(
  titlePanel("Plot tree"),
  sidebarLayout(
    sidebarPanel(
    
    tabsetPanel(
    
    tabPanel("tree", 
      		fileInput('tree', 'Choose tree file', multiple=F,
                accept=c('biotree/newick', '.nwk', '.tree'))
		),
 
 	tabPanel("metadata", 
      fileInput('info', 'Choose info file', multiple=F,
                accept=c('text/csv', '.csv'))
    ),
		
	tabPanel("heatmap", 						 
		fileInput('heatmap', 'Choose heatmap file', multiple=F,
                accept=c('text/csv', 
								 '.csv'))
	)
	)
 
    ),
    mainPanel(
      plotOutput("Tree", height=2000))
    )
  )
)