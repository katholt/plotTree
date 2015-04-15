library(shiny)
library(ape)

shinyUI(fluidPage(
  titlePanel("Plot tree"),
  sidebarLayout(
    sidebarPanel(
      fileInput('tree', 'Choose tree file', multiple=F,
                accept=c('biotree/newick', 
								 '.nwk', '.tree'))
    ),
    mainPanel(
      plotOutput("Tree", height=2000))
    )
  )
)