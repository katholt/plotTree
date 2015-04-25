library(shiny)
library(ape)

shinyUI(fluidPage(
  titlePanel("Plot tree"),
  sidebarLayout(
    sidebarPanel(
      fileInput('tree', 'Choose tree file', multiple=F,
                accept=c('biotree/newick', '.nwk', '.tree')),
      
      checkboxInput("chk_metadata", "Metadata file", value = FALSE),
      
      conditionalPanel(
        condition = "input.chk_metadata",
        fileInput('info', 'Choose metadata file', multiple = FALSE, accept = c('text/csv', '.csv'))
      ),
      
      checkboxInput("chk_heatmap", "Heatmap file", value = FALSE),
      conditionalPanel(
        condition = "input.chk_heatmap",
        fileInput('heatmap', 'Choose heatmap file', multiple = F, accept = c('text/csv', '.csv'))
        )
    ),
         
    mainPanel(plotOutput("Tree", height=2000))
  )
)
)