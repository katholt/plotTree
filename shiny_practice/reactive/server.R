library(shiny)
library(ape)
source("plotTree.R")

shinyServer(function(input, output, session) {

	tree <- eventReactive(input$drawButton, {
    	input$tree
  	})

	info <- eventReactive(input$drawButton, {
    	input$info_file
  	})

	heatmap <- eventReactive(input$drawButton, {
    	input$heatmap
  	})
  	
	cluster <- eventReactive(input$drawButton, {
    	input$clustering
  	})

	colour_nodes <- eventReactive(input$drawButton, {
    	input$colour_nodes
  	})
  	
  	tip_size <- eventReactive(input$drawButton, {
    	input$tip_size
  	})
  	
  	
  	# heatmap colours
  	start_col <- eventReactive(input$drawButton, {
    	input$start_col
  	})  	
  	middle_col <- eventReactive(input$drawButton, {
    	input$middle_col
  	}) 	
  	end_col <- eventReactive(input$drawButton, {
    	input$end_col
  	})
  	heatmap_breaks <- eventReactive(input$drawButton, {
    	input$heatmap_breaks
  	})
  	
  	
  	highlight_column <- eventReactive(input$drawButton, {
    	input$highlight_column
  	})
  	
  	show_column <- eventReactive(input$drawButton, {
    	input$show_column
  	})
  	
  	
  	# track data types
  	chk_heatmap <- eventReactive(input$drawButton, {
    	input$chk_heatmap
  	})
  	
  	info_data <- eventReactive(input$drawButton, {
    	input$info_data
  	})
  	
  	returnDownload <- eventReactive(input$printButton, {
    	input$returnDownload
  	})
  	
  	download_type <- eventReactive(input$printButton, {
    	input$download_type
  	})
  	
  	h <- eventReactive(input$printButton, {
    	input$h
  	})

  	w <- eventReactive(input$printButton, {
    	input$w
  	})
  	  	
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
			updateSelectInput(session, inputId='highlight_column', choices=info_cols)
			updateSelectInput(session, inputId='show_column', choices=info_cols)
		}
	)
  	
  	
  output$Tree <- renderPlot({

	highlight_column <- highlight_column()
	show_column <- show_column()
	treeFile <- tree()
	infoFile <- info()
    heatmapFile <- heatmap()
    cluster <- cluster()
    colour_nodes <- colour_nodes()
    tip_size <- tip_size()
    start_col <- start_col()
    middle_col <- middle_col()
    end_col <- end_col()
    heatmap_breaks <- as.integer(heatmap_breaks())
    
    chk_heatmap <- chk_heatmap()
    info_data <- info_data()
    
    returnDownload <- returnDownload()
    download_type <- download_type()
    h <- h()
    w <- w()
    
    if (is.null(treeFile))
      return(NULL)
      
    if (!info_data) {
      infoFile <- NULL
    } 
    else {
    	infoFile <- infoFile$datapath
	}
    
    if (!chk_heatmap) {
      heatmapFile <- NULL
    } else {
      heatmapFile <- heatmapFile$datapath
    }

      
    doPlotTree <-function(){  
    
    	plotTree(tree=treeFile$datapath,infoFile=infoFile,
      		heatmapData=heatmapFile,cluster=cluster,colourNodesBy=highlight_column,
      		infoCols=show_column,
      		tip.colour.cex=tip_size,heatmap.colours=colorRampPalette(c(start_col,middle_col,end_col),space="rgb")(heatmap_breaks)) 
    }
    
    

### SAVE FIGURE
      
      if(returnDownload){
if(download_type == 'PDF'){
                pdf("plot.pdf", width=as.numeric(w*0.039370), height=as.numeric(h*0.039370))
                doPlotTree()
                dev.off()

              output$pdflink <- downloadHandler(
            filename <- "myplot.pdf",
            content <- function(file) {
                file.copy("plot.pdf", file)
            })
} else if (download_type == "PNG"){
png("plot.png", width=as.numeric(w), height=as.numeric(h), units='mm', res=200)
                doPlotTree()
                dev.off()
              output$pdflink <- downloadHandler(
            filename <- "myplot.png",
            content <- function(file) {
                file.copy("plot.png", file)
            })
} else {
stop(paste("Unexpected type returned:", download_type))
}
            }
            
### END SAVE FIGURE   

      doPlotTree()
      
  })
  
})