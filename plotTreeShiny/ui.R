library(shiny)
library(ape)
library(RLumShiny)
shinyUI(fluidPage(
  fluidRow( ## top row to holds all dynamic input 
    ## column to hold all tabset panel 
    column(12, tabsetPanel(
      ## Tree tab
      tabPanel("Tree",
               ## UPLOAD TREE
               ## start tree fluidRow
               fluidRow(
                 ## column for uploading tree
                 column(6, wellPanel( 
                 br(),
                 fileInput('tree_file', 'Upload tree file (nwk)', multiple=F,
                           accept=c('biotree/newick','.nwk', '.tree')),
                 ## checkbox to display tree parameters list
                 checkboxInput("show_tree_param_list", "Show/hide tree display settings.", value=FALSE)
               )), ## finish column for tree upload
               
               conditionalPanel(
                 condition = "input.show_tree_param_list",
                 ## column to hold tree parameters list on the right-hand side
                 column(6, wellPanel(
                   
                   ## checkbox to label tree tips with strain IDs
                   checkboxInput("label_tips", "Label tree tips?", value=FALSE),
                   conditionalPanel(
                     condition = "input.label_tips",                     
                     textInput("tip_label_size", label = "Text size", value = "1"),
                     textInput("offset", label = "Offset", value = "0")), ## finish condition for tips label 
                   
                   ## Options for user to input branch thickness and colour
                   textInput("tree_line_width", label = "Branch width", value = "1.5"),
                   jscolorInput(inputId="branch_colour", label="Branch colour:", value="#000000", 
                                position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T)
                 )) ## finish column for param list
                 ) ## finish show param list condition 
               ) ## finish tree fluidRow
      ), # Finished tree tab	
      
      ## Metadata tab
      tabPanel("Metadata",
               
               ### UPLOAD METADATA (info file)
               ## start metadata fluidRow
               fluidRow(
                 ## column for uploading metadata
                 column(6, wellPanel(
                 br(),
                 fileInput('info_file', 'Upload metadata (CSV)'),
                 
                 ## checkbox for server.R to track that metadata is uploaded
                 checkboxInput('chk_info', 'Use metadata', value = FALSE),
                 
                 ## checkbox to display metadata parameters list
                 checkboxInput("show_info_param_list", "Show/hide metadata display settings.", value=FALSE)
               )), ## finish column for metadata upload
               
               conditionalPanel(
                 condition = "input.chk_info",    
                 conditionalPanel(
                   condition="input.show_info_param_list",
                   fluidRow(
                     ## column for part1 of parameters list
                     column(3, wellPanel(
                       h4("Metadata options"),
                       
                       ## checkbox for printing metadata as text
                       checkboxInput('chk_print_metadata', 'Print metadata as text', value = FALSE),
                       conditionalPanel(
                         condition = "input.chk_print_metadata",
                         selectInput('select_columns', 'Metadata to print:', c(''), multiple=TRUE)
                       ), ## finish condition for metadata printing as text
                       "--------",
                       selectInput('colour_tips_by', 'Colour tips by:', c(''))
                     )), ## finish column for part1
                     
                     # options if colouring tips
                     conditionalPanel(
                       condition = "input.colour_tips_by != '(none)'",
                       
                       ## column for part2 of parameters list
                       column(3, wellPanel(
                         
                         ## slider for adjusting tip node size
                         sliderInput("tip_size", label = "Tip size", min = 0.1, max = 20, value = 0.5),
                         
                         ## checkbox to display legend for selected metadata
                         checkboxInput("legend", "Legend for node colours?", value=TRUE),
                         
                         ## menu-list for location of the legened on user screen
                         selectInput("legend_pos", label = "Position for legend", 
                                     choices = list( "bottomleft"="bottomleft", "bottomright"="bottomright",
                                                     "top-left"="topleft", "topright"="topright")
                         ), 
                         "--------",
                         ## checkbox for ancestral state reconstruction 
                         checkboxInput("ancestral", "Ancestral state reconstruction?", value=FALSE),
                         
                         ## slider for adjusting pie-chart size, plotted on tree nodes
                         sliderInput("pie_size", label = "Pie graph size", min = 0.1, max = 20, value = 0.5)
                       )) ## finish column for part2
                     ) ## finish condition for tips colouring
                     ) ## finish fluidRow for params part1 and part2
                 )) ## finish conditions for chk_info && show param list
               ) ## finish metadata fluidRow
               ),	# Finished metadata tab	
      
      
      ## Heatmap tab
      tabPanel("Heatmap",
               
               ### UPLOAD HEATMAP DATA
               ## Start heatmap fluidrow
               fluidRow(
                 ## column for heatmap upload
                 column(6, wellPanel(
                 br(),
                 fileInput('heatmap_file', 'Upload heatmap file (CSV)', multiple = F, accept = c('text/csv', '.csv')),
                 
                 ## xheckbox for server.R to track that heatmap is uploaded
                 checkboxInput('chk_heatmap', 'Plot heatmap', value = FALSE),
                 
                 ## checkbox to display heatmap parameters list
                 checkboxInput("show_heatmap_param_list", "Show/hide heatmap display settings.", value=FALSE)
               )), ## finish column for heatmap upload
               
               conditionalPanel(
                 condition = "input.chk_heatmap",
                 conditionalPanel(
                   condition="input.show_heatmap_param_list",
                   fluidRow(
                     ## column for part1 of parameters list
                     column(3, wellPanel(    
                       h4("Heatmap options"),
                       selectInput("clustering", label = h5("Clustering:"), 
                                   choices = list("Select..."=F, "Cluster columns by values"=T, "Square matrix"="square"),
                                   selected = "Select"), 
                       
                       #					checkboxInput("heatColoursSpecify", "Specify heatmap colours manually", value=FALSE),
                       #					conditionalPanel(
                       #						condition = "input.heatColoursSpecify",
                       #						textInput("heatmap_colour_vector", label = "R code (vector), e.g. rev(gray(seq(0,1,0.1)))", value = "")
                       #					),
                       "--------",
                       textInput("heatmap_decimal_places", label = "Decimal places to show in heatmap legend:", value = "1"),
                       textInput("col_label_cex", label = "Text size for column labels:", value = "0.75")
                       #  				textInput("vlines_heatmap", label = "y-coordinates for vertical lines (e.g. c(2,5)):", value = ""),
                       #					jscolorInput(inputId="vlines_heatmap_col", label=h5("Colour for vertical lines:"), value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T)
                     )), ## finish column for part1
                     
                     ## column for part2 of parameters list
                     column(3, wellPanel(  
                       
                       # OPTIONALLY DISPLAY COLOUR OPTIONS
                       checkboxInput("heat_colours_prompt", "Change heatmap colour ramp", value=FALSE),
                       conditionalPanel(
                         condition = "input.heat_colours_prompt", 
                         jscolorInput(inputId="start_col", label="Start colour:", value="FFFFFF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
                         jscolorInput(inputId="middle_col", label="Middle colour:", value="FFF94D", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
                         jscolorInput(inputId="end_col", label="End colour:", value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
                         textInput("heatmap_breaks", label = "Breaks:", value = "100")
                       ) ## finish condition for heatmap colours prompt
                     )) ## finish column for part2
                   ) ## finish fluidrow for part1 and part2
                 )) ## finish conditions for chk_heatmap && show param list
               ) ## finish heatmap fluidRow
      ), # finished heatmap tab
      
      tabPanel("Other",
               ## start Others fluidRow
               fluidRow(
                 ## column for others upload section
                 column(6, wellPanel(
                 tabsetPanel(
                   tabPanel("Barplots",
                            br(),
                            # bar plots file upload
                            fileInput('bar_data_file', 'Upload data for bar plots (CSV)', multiple = F, accept = c('text/csv', '.csv')),
                            
                            ## checkox for server.R to track bar plot file upload
                            checkboxInput('chk_barplot', 'Plot bar graphs', value = FALSE),
                            
                            conditionalPanel(
                              condition = "input.chk_barplot", h4("Barplot options"),
                              
                              ## options to of bar plot colour
                              jscolorInput(inputId="bar_data_col", label="Colour for barplots:", value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T)
                            ) ## finish condition on file upload
                   ), ## finish barplot tab
                   
                   tabPanel("Genome blocks",
                            br(),
                            
                            fileInput('blocks_file', 'Upload genome block coordinates', multiple = F, accept = c('text/tab', '.txt')),
                            
                            ## checkbox for server.R to track bar genome blocks file upload
                            checkboxInput('chk_blocks', 'Plot genome blocks', value = FALSE),
                            
                            conditionalPanel(
                              condition = "input.chk_blocks", h4("Genome block plotting options"),
                              
                              ## parameters settings for plotting genome blocks
                              textInput("genome_size", label = "Genome size (bp):", value = "5E6"),
                              jscolorInput(inputId="blocks_colour", label="Colour for blocks:", value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T),
                              sliderInput("blwd", label = "Block size", min = 0.1, max = 20, value = 5)
                            ) ## finish conditions for chk_blocks 
                   ), ## finish genome blocks tab
                   
                   tabPanel("SNPs",
                            br(),
                            # snps file upload
                            fileInput('snps_file', 'Upload SNP allele table (CSV)', multiple = F, accept = c('text/csv', '.csv')),
                            
                            ## checkox for server.R to track snps file upload
                            checkboxInput('chk_snps', 'Plot SNPs', value = FALSE),
                            
                            conditionalPanel(
                              condition = "input.chk_snps", h4("SNP plotting options"),
                              
                              ## parameters settings for plotting snps data
                              textInput("genome_size", label = "Genome size (bp):", value = "5E6"), # make this linked to previous conditional 
                              jscolorInput(inputId="snps_colour", label="Colour for SNPs:", value="1755FF", position = "bottom", color = "transparent", mode = "HSV", slider = T, close = T)
                            )
                   ) ## finish snps tab
                 ) #finished other data subtabs
               )))), # finished other data tab
      
      tabPanel("Layout",
               ## start layout fluidrow
               fluidRow(
                 ## column for all 'layout' contents
                 column(6, wellPanel(
                 br(),
                 h5("Relative widths"),
                 
                 ## options for adjusting tree/data dimensions
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
               )) ## finish column layout
               ) ## finish layout fluidrow
               ) ## finish Layout tab
      
    ) # finish tabsetPanel
    ) # finish tabsetpanel column
  ), # finish first fluidRow 
  
  ### DRAW BUTTON in a separate fluidRow
  fluidRow(
    column(12, 
           actionButton("draw_button", "Draw!"))),
  
  ## ADD PRINT BUTTON HERE ##
  
  br(),
  ## main panel for displaying tree/data in a separate fluidRow
  fluidRow(
    column(12, wellPanel(
      plotOutput("Tree", height=800)
    )))
  
) # fluidPage
) # shinyUI