 sidebarPanel(
 	checkboxInput('returnDownload', 'Download figure?', FALSE),
	conditionalPanel(
            condition = "input.returnDownload == true",
			radioButtons("download_type", "Download type:",
             c("PDF" = "PDF",
               "PNG" = "PNG")),            
            sliderInput(inputId="w", label = "width (A4=210mm):", min=60, max=600, value=210, width='80%', ticks=F),
            sliderInput(inputId="h", label = "height (A4=297mm):", min=60, max=600, value=297, width='80%', ticks=F),
            br(),
            downloadLink('pdflink')    
    ),
  actionButton("printButton", "Update print settings")
    ),