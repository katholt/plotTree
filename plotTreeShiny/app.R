library(shiny)
library(ape)
library(RLumShiny)
source("plotTree.R")

# Please run this application in an external web browser but the built-in browser of shiny
# Files: bin\app.R and bin\plotTree.R
# Use runApp(appDir = "bin") to execute this application

#======================== User interface ========================

ui <- fluidPage(
  
  #titlePanel("Plot tree"),
  sidebarLayout(
    sidebarPanel(
      tabsetPanel(
        tabPanel("Tree",      
          ### UPLOAD TREE
          br(),
          fileInput('tree_file', 'Upload tree file (nwk)', multiple = FALSE,
                    accept = c('biotree/newick','.nwk', '.tree')),
          checkboxInput("label_tips", "Label tree tips?", value = FALSE),
          conditionalPanel(
            condition = "input.label_tips",
            textInput("tip_label_size", label = "Text size", value = "1"),
            textInput("offset", label = "Offset", value = "0")
          ),    
          textInput("tree_line_width", label = "Branch width", value = "1.5"),
          jscolorInput(inputId = "branch_colour", label = "Branch colour:", value = "#000000", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
          br()
        ), # finished tree tab	
        
        tabPanel("Info",      
          ### METADATA (info file)
          br(),
          fileInput('info_file', 'Upload metadata (CSV)'),
          checkboxInput('chk_info', 'Use metadata', value = FALSE),
          conditionalPanel(
            condition = "input.chk_info",
            checkboxInput('print_metadata', 'Print columns', value = FALSE),
            conditionalPanel(
              condition = "input.print_metadata",
              selectInput('print_column', 'Metadata columns to print:', c(''), multiple=TRUE)
            ),
            "--------",
            selectInput('colour_tips_by', 'Colour tips by:', c('')),
            # options if colouring by tips
            conditionalPanel(
              condition = "input.colour_tips_by != '(none)'",
              sliderInput("tip_size", label = "Tip size", min = 0.1, max = 20, value = 0.5),
              ### COLOUR PANELS
              checkboxInput("legend", "Legend for node colours?", value=TRUE),
              selectInput("legend_pos", label = "Position for legend", 
                          choices = list( "bottomleft"="bottomleft", "bottomright"="bottomright",
                                          "top-left"="topleft", "topright"="topright")
              ), 
              "--------",
              checkboxInput("ancestral", "Ancestral state reconstruction?", value=FALSE),
              sliderInput("pie_size", label = "Pie graph size", min = 0.1, max = 20, value = 0.5)
            )
          )
        ),	# finished metadata tab	
        
        tabPanel("Data", 
          ### HEATMAP DATA
          br(),
          fileInput('heatmap_file', 'Upload heatmap file (CSV)', multiple = F, accept = c('text/csv', '.csv')),
          checkboxInput('chk_heatmap', 'Plot heatmap', value = FALSE),  
          conditionalPanel(
            condition = "input.chk_heatmap", h4("Heatmap options"),
            selectInput("clustering", label = h5("Clustering:"), 
                        choices = list("Select..." = F, "Cluster columns by values" = T, "Square matrix"="square"),
                        selected = "Select"), 
            "--------",
            # OPTIONALLY DISPLAY COLOUR OPTIONS
            checkboxInput("heat_colours_prompt", "Change heatmap colour ramp", value = FALSE),
            conditionalPanel(
              condition = "input.heat_colours_prompt", 
              jscolorInput(inputId = "start_col", label = "Start colour:", value = "FFFFFF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
              jscolorInput(inputId = "middle_col", label = "Middle colour:", value = "FFF94D", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
              jscolorInput(inputId = "end_col", label = "End colour:", value = "1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
              textInput("heatmap_breaks", label = "Breaks:", value = "100")
            ),
            #					checkboxInput("heatColoursSpecify", "Specify heatmap colours manually", value=FALSE),
            #					conditionalPanel(
            #						condition = "input.heatColoursSpecify",
            #						textInput("heatmap_colour_vector", label = "R code (vector), e.g. rev(gray(seq(0,1,0.1)))", value = "")
            #					),
            "--------",
            textInput("heatmap_decimal_places", label = "Decimal places to show in heatmap legend:", value = "1"),
            textInput("col_label_cex", label = "Text size for column labels:", value = "0.75")
            #					textInput("vlines_heatmap", label = "y-coordinates for vertical lines (e.g. c(2,5)):", value = ""),
            #					jscolorInput(inputId="vlines_heatmap_col", label=h5("Colour for vertical lines:"), value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T)
          )
        ), # finished heatmap options
        
        tabPanel("Other",
          tabsetPanel(
            tabPanel("Barplots",
                      br(),
                      # bar plots
                      fileInput('bar_data_file', 'Upload data for bar plots (CSV)', multiple = F, accept = c('text/csv', '.csv')),
                      checkboxInput('chk_barplot', 'Plot bar graphs', value = FALSE),
                      conditionalPanel(
                        condition = "input.chk_barplot", h5("Barplot options"),
                        jscolorInput(inputId = "bar_data_col", label = "Colour for barplots:", value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T)
                      )
                    ),
            tabPanel("Genome blocks",
                      br(),
                      # genome blocks
                      fileInput('blocks_file', 'Upload genome block coordinates', multiple = F, accept = c('text/tab', '.txt')),
                      checkboxInput('chk_blocks', 'Plot genome blocks', value = FALSE),
                      conditionalPanel(
                        condition = "input.chk_blocks", h5("Genome block plotting options"),
                        textInput("genome_size", label = "Genome size (bp):", value = "5E6"),
                        jscolorInput(inputId = "blocks_colour", label = "Colour for blocks:", value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
                        sliderInput("blwd", label = "Block size", min = 0.1, max = 20, value = 5)
                      )
            ),
                   
            tabPanel("SNPs",
                      br(),
                      # snps
                      fileInput('snps_file', 'Upload SNP allele table (CSV)', multiple = F, accept = c('text/csv', '.csv')),
                      checkboxInput('chk_snps', 'Plot SNPs', value = FALSE),
                      conditionalPanel(
                        condition = "input.chk_snps", h5("SNP plotting options"),
                        textInput("genome_size", label = "Genome size (bp):", value = "5E6"), # make this linked to previous conditional 
                        jscolorInput(inputId = "snps_colour", label = "Colour for SNPs:", value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T)
                      )
            )
          ) #finished tabsetPanels
        ), # finished other data tab
        
        tabPanel("Layout",
                 br(),
                 h5("Relative widths"),
                 textInput("tree_width", label = "Tree", value = 10),
                 textInput("info_width", label = "Info columns", value = 10),
                 textInput("heatmap_width", label = "Heatmap", value = 30),
                 textInput("bar_width", label = "Bar plots", value = 10),
                 textInput("genome_width", label = "Genome data (blocks, SNPs)", value = 10),
                 br(),
                 h5("Relative heights"),
                 textInput("main_height", label = "Main  panels", value = 100),
                 textInput("label_height", label = "Heatmap labels", value = 10),
                 br(),
                 h5("Borders"),
                 textInput("edge_width", label = "Border width/height", value = 1)
        ),
        
        # Settings and the button for printing
        tabPanel("Save",
                 br(),  # prints an empty line in the html file that is displayed as the UI
                 radioButtons(inputId = "format", label = "Download type:",
                              choices = c("PNG" = "png", "PDF" = "pdf"), selected = "png"),
                 sliderInput(inputId = "w", label = "width (A4 = 210mm):", min = 180, max = 1200, value = 210, width = '80%', ticks = FALSE),
                 sliderInput(inputId = "h", label = "height (A4 = 297mm):", min = 180, max = 1200, value = 297, width = '80%', ticks = FALSE),
                 textInput("file_name", label = "File name", value = "figure"),  # The default file name is "figure".
                 downloadButton('downloadButton')  # This will generate a new variable 'downloadbutton'
        )  # end of tabPanel "Save"
      ), # finish tabsetPanel
      
      ### DRAW BUTTON
      br(),
      actionButton("draw_button", "Draw!")
      ),  # end of the sidebarPanel
    
    mainPanel(
      plotOutput("Tree", height = 800)
    )
  ) # finished sidebarLayout
) # end of fluidPage and the ui

#======================== Server =========================

server <- function(input, output, session) {
  
  # An event observer for changes to INFO CSV file
  observeEvent(input$info_file, 
  {
    # read the CSV file and get the column names.
    # re-reading this file repeatedly is inefficient
    df <- read.table(input$info_file$datapath, header = TRUE, sep = ',')
    
    # build a list of values, this is what is required by update methods
    info_cols <- list()
    for (v in colnames(df)) {
      info_cols[v] <- v
    }
    # update the two input widgets using the column names
      
    updateSelectInput(session, inputId = 'colour_tips_by', choices=c('(none)',info_cols[-1]))
    updateSelectInput(session, inputId = 'print_column', choices=c(info_cols[-1]))
      
    # switch on the meta data plotting option
    updateCheckboxInput(session, inputId = 'info_data', value=TRUE)
  })  # end of observeEvent

  # An event observer for changes to HEATMAP file
  observeEvent(input$heatmap_file, 
  {
    # switch on the heatmap plotting option
    updateCheckboxInput(session, inputId = 'chk_heatmap', value=TRUE)
  })	
  
  # An event observer for changes to BAR DATA file
  observeEvent(input$bar_data_file, 
  {
    # switch on the heatmap plotting option
    updateCheckboxInput(session, inputId = 'chk_barplot', value=TRUE)
  })	
  
  # An event observer for changes to BLOCKS file
  observeEvent(input$blocks_file, 
  {
    # switch on the heatmap plotting option
    updateCheckboxInput(session, inputId = 'chk_blocks', value=TRUE)
  })	
  
  # An event observer for changes to SNPs file
  observeEvent(input$snps_file, 
  {
    # switch on the heatmap plotting option
    updateCheckboxInput(session, inputId = 'chk_snps', value=TRUE)
  })
  
  ### PLOT THE TREE: defines the main plotting function which will be called by downloadHandler() as well
  doPlotTree <-function() {
    ### ALL VARIABLES PULLED FROM 'input' GO INSIDE HERE
    isolate ({
      
      l <- input$Layout
      t <- input$Tree
      i <- input$Info
      o <- input$Other
      d <- input$Data
      
      tree_file <- input$tree_file$datapath
      
      # tree plotting options
      label_tips <- input$label_tips
      tree_line_width <- as.integer(input$tree_line_width)
      branch_colour <- input$branch_colour
      tip_label_size <- as.integer(input$tip_label_size)
      offset <- as.integer(input$offset)
      
      # metadata variables
      info_file <- input$info_file$datapath
      tip_size <- input$tip_size
      colour_tips_by <- input$colour_tips_by
      if (colour_tips_by == '(none)') {colour_tips_by <- NULL}
      ancestral <- input$ancestral
      pie_size <- input$pie_size
      legend <- input$legend
      legend_pos <- input$legend_pos
      print_column <- input$print_column
      print_metadata <- input$print_metadata
      if (!print_metadata) { print_column <- NA }
      
      # heatmap variables
      heatmap_file <- input$heatmap_file$datapath
      cluster <- input$clustering
      heatmap_decimal_places <- as.integer(input$heatmap_decimal_places)
      col_label_cex <- as.integer(input$col_label_cex)
      vlines_heatmap_col <-input$vlines_heatmap_col
      vlines_heatmap <- input$vlines_heatmap
      
      #    	heatColoursSpecify <- input$heatColoursSpecify
      
      #			if (heatColoursSpecify) {
      #				heatmap_colours <- input$heatmap_colour_vector
      #			}
      #			else {
      heatmap_colours <- colorRampPalette(c(input$start_col,input$middle_col,input$end_col),space="rgb")(as.integer(input$heatmap_breaks))
      #			}
      
      # barplot variables
      bar_data_file <- input$bar_data_file$datapath
      bar_data_col <- input$bar_data_col
      
      # block plot variables
      blocks_file <- input$blocks_file$datapath
      blocks_colour <- input$blocks_colour
      blwd <- input$blwd
      genome_size <- input$genome_size
      
      snps_file <- input$snps_file$datapath
      snps_colour <- input$snps_colour
      
      # Layout/spacing
      tree_width <- as.numeric(input$tree_width)
      info_width <- as.numeric(input$info_width)
      heatmap_width <- as.numeric(input$heatmap_width)
      bar_width <- as.numeric(input$bar_width)
      genome_width <- as.numeric(input$genome_width)
      main_height <- as.numeric(input$main_height)
      label_height <- as.numeric(input$label_height)
      edge_width <- as.numeric(input$edge_width)
      
      # TRACK DATA TYPES TO PLOT
      chk_heatmap <- input$chk_heatmap
      chk_info <- input$chk_info
      chk_barplot <- input$chk_barplot
      chk_blocks <- input$chk_blocks
      chk_snps <- input$chk_snps
      
      if (is.null(tree_file)) { return(NULL) }
      
      if (!chk_info) { info_file <- NULL } 
      else { info_file <- info_file }
      
      if (!chk_heatmap) { heatmap_file <- NULL } 
      else { heatmap_file <- heatmap_file }
      
      if (!chk_barplot) { bar_data_file <- NULL } 
      else { bar_data_file <- bar_data_file }
      
      if (!chk_blocks) { blocks_file <- NULL } 
      else { blocks_file <- blocks_file }
      
      if (!chk_snps) { snps_file <- NULL } 
      else { snps_file <- snps_file } 
      
    }) # end isolate
    
    # underlying call to plotTree(), drawn to screen and to file
    plotTree(tree = tree_file, 
             tip.labels = label_tips, tipLabelSize = tip_label_size, offset = offset,
             lwd = tree_line_width, edge.color = branch_colour,
             infoFile = info_file, infoCols = print_column, 
             colourNodesBy = colour_tips_by, tip.colour.cex = tip_size, 
             ancestral.reconstruction = ancestral, pie.cex = pie_size, 
             legend = legend, legend.pos = legend_pos,
             heatmapData = heatmap_file, cluster = cluster,
             heatmap.colours = heatmap_colours,
             heatmapDecimalPlaces = heatmap_decimal_places, colLabelCex = col_label_cex,
             vlines.heatmap = vlines_heatmap, vlines.heatmap.col = vlines_heatmap_col,
             barData = bar_data_file, barDataCol = bar_data_col,
             blockFile = blocks_file, block_colour = blocks_colour, blwd = blwd,
             genome_size = genome_size,
             snpFile = snps_file, snp_colour = snps_colour,
             treeWidth = tree_width, infoWidth = info_width, dataWidth = heatmap_width,
             barDataWidth = bar_width, blockPlotWidth = genome_width, 
             mainHeight = main_height, labelHeight = label_height, edgeWidth = edge_width
    ) 
  }
  
  output$Tree <- renderPlot({
    input$draw_button  # do not need to reset the draw_button value which increases by every click
    doPlotTree()
  }) # end render plot
  
  # downloads a high-definition plot of the input data
  # This function is called when the download button is clicked
  output$downloadButton <- downloadHandler(
    
    filename = function() {
      # This is the default file name displayed in the download box poped up after clicking the download button.
      # You can change the filename in the download box.
      f <- input$file_name
      if(input$format == "pdf"){
        return(paste(f, ".pdf", sep = ""))
      } else {
        return(paste(f, ".png", sep = ""))
      }
    },
    
    content = function(tmp) {
      # tmp: the file name of a non-existent temp file.
      if(input$format == "pdf"){
        MM2Inch <- 0.03937  # convert to millimetres to inches because the unit for pdf(..) is inch.
        pdf(tmp, width = as.numeric(input$w) * MM2Inch, height = as.numeric(input$w) * MM2Inch, paper = "special")  
        # "special": the paper size is specified by the width and height; a4r: landscape orientation
          doPlotTree()  # redraw the plot
        dev.off()
      } else {
        png(tmp, width = as.numeric(input$w), height = as.numeric(input$w), units = "mm", res = 72)
        # res: the resolution is set to 72 ppi
          doPlotTree()  # redraw the plot
        dev.off()
      }
    }
  )
} # end of the function server(..)

#======================== Executes the whole script =========================

shinyApp(ui = ui, server = server)
