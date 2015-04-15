library(shiny)
library(ape)
source("plotTree.R")

shinyServer(function(input, output) {
  output$Tree <- renderPlot({

    treeFile <- input$tree
    infoFile <- input$info
    heatmapFile <- input$heatmap
    
    if (is.null(treeFile))
      return(NULL)
    
            if(input$returnDownload){
if(input$type == 'PDF'){
                pdf("plot.pdf", width=as.numeric(input$w*3.94), height=as.numeric(input$h*3.94))
                plotTree(tree=treeFile$datapath,infoFile=infoFile$datapath,heatmapData=heatmapFile$datapath)
                dev.off()

              output$pdflink <- downloadHandler(
            filename <- "myplot.pdf",
            content <- function(file) {
                file.copy("plot.pdf", file)
            })
#} else if (input$type == "SVG"){
#svg("myplot.svg", width=as.numeric(input$w*3.94), height=as.numeric(input$h*3.94))
#                plotTree(tree=treeFile$datapath,infoFile=infoFile$datapath,heatmapData=heatmapFile$datapath)
#                dev.off()
#              output$pdflink <- downloadHandler(
#            filename <- "myplot.svg",
#            content <- function(file) {
#                file.copy("plot.svg", file)
#            })
} else if (input$type == "PNG"){
png("plot.png", width=as.numeric(input$w*3.94), height=as.numeric(input$h*3.94))
                plotTree(tree=treeFile$datapath,infoFile=infoFile$datapath,heatmapData=heatmapFile$datapath)
                dev.off()
              output$pdflink <- downloadHandler(
            filename <- "myplot.png",
            content <- function(file) {
                file.copy("plot.png", file)
            })
} else {
stop(paste("Unexpected type returned:", input$type))
}
            }
plotTree(tree=treeFile$datapath,infoFile=infoFile$datapath,heatmapData=heatmapFile$datapath)
      
  })
})
