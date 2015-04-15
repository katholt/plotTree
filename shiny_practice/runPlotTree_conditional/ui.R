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
								 
	fileInput('heatmap', 'Choose heatmap file', multiple=F,
                accept=c('text/csv', 
								 '.csv'))
 
    ),
    mainPanel(
      plotOutput("Tree", height=2000))
    )
  )
)