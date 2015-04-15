library(shiny)
library(ape)

shinyUI(fluidPage(
  titlePanel("Plot tree"),
  sidebarLayout(
    sidebarPanel(
      fileInput('tree', 'Choose tree file', multiple=F,
                accept=c('biotree/newick', '.nwk', '.tree')),
      # This prompts the user for metadata file
      checkboxInput("chk_meta", "Meta file"),
      conditionalPanel(
        condition = "input.chk_meta",
        fileInput('info', 'Choose info file', multiple = F, accept = c('text/csv', '.csv'))        
      ),
      
      # This prompts the user for pan genome file
      checkboxInput("chk_heatmap", "Heatmap file"),
      conditionalPanel(
        condition = "input.chk_heatmap", "Heatmap",
        fileInput('heatmap', 'Choose heatmap file', multiple = F, accept = c('text/csv', '.csv')),
        
        # This displays a check box if the user wants to change tree options
        checkboxInput("optionsPrompt", "Check box if you wish to not use the default values.", value=FALSE),
        conditionalPanel(
          condition = "input.optionsPrompt", 
          selectInput("clustering", label = "Columns clustering:", 
                      choices = c("Select", "Cluster based on density", "Cluster according to tree"), selected = "Select"), "Note: You can only cluster according to tree if your rows are equal to your tree tips. 
             I.e. if you're viewing the dataset against itself.")
      )
    ),
    
    mainPanel(plotOutput("Tree", height=2000))
  )
)
)