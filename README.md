# plotTree

This is R code for plotting a phylogenetic tree and annotating the leaves with various information, including: 
- colouring tips according to some variable (provided in infoFile; CSV format with column 1 = tip names)
- printing columns of text next to the leaves (provided in infoFile; CSV format with column 1 = tip names)
- printing heatmaps of data (provided in heatmapData; numerical data in CSV format with column 1 = tip names)
- printing horizontal bar graphs next to the tips (provided in barData; numerical data in CSV format with column 1 = tip names)
- printing the location of SNPs (snpFile; allele data in CSV format with row 1 = tip names; SNPs relative to reference, either column 1 or a specified strain)
- printing the location of genome blocks (blockFile; tab delimited file with col 1 = tip name, col 2 = start, col 3 = stop)

There are also options to:
- cluster the heatmap data using any method available in hclust
- perform ancestral discrete trait reconstruction using ace and plot the results as pie graphs on each node of the tree

# Overview

1) Prepare your tree file (to be passed to the function via tree="tree.nwk")
--
- newick format
- no hashes in the strain names (trees can't be read into R if they have hashes)
- alternatively, this can be an R object of the class 'phylo' (can convert hclust object to this format using as.phylo())

2) Prepare your data files
--
- you can provide any or all of strain info, data to be plotted as a heatmap, data to be plotted as a bar chart, snp allele table in the order: tree | info | heatmap | barplot | SNPS/blocks
- CSV format, one row per strain (EXCEPT SNP allele table or blocks files, which contain coordinates of SNPs and blocks, see above)
- column 1 contains strain names, precisely matching those in the tree file
- row 1 contains variable names
- alternatively, these can be R objects of class 'matrix' or 'data.frame'

3) Optional input data files (any combination can be provided, but they will always be plotted in this order across the page, with the tree on the left):
--
(i) Strain info / metadata (to be passed to the function via infoFile="info.csv")
- the values in the columns will be printed (in columns) next to the tree
- optionally, if you have lots of columns and only want to print some of them, you can specify the names of the columns to print using infoCols=c("variable1","variable2"); otherwise all columns will be printed
- optionally, if you want to colour the tree tips according to the value of one of the data columns, specify the name of the variable via colourNodesBy="variable"; you can also perform ancestral trait reconstruction on this variable and plot the results as pie graphs, to turn this on use ancestral.reconstruction=T

(ii) Numeric values to plot as a heatmap (to be passed to the function via heatmapData="data.csv")

(iii) One column of numeric values to plot as a barplot (to be passed to the function via barData="bar.csv")

(iv) SNP allele table (to be passed to the function via snpFile="alleles.csv")
 will plotted to indicate the position of SNPs in each strain, where SNPs are defined as differences COMPARED TO THE ALLELES IN COLUMN 1. So, your alleles in column one should be the inferred ancestral alleles (e.g. those of an outgroup).
- note you need to specify the total size of the genome in base pairs, to set up the appropriate X-axis; set using genome_size
- unknown alleles or gaps should not be plotted as SNPs compared to the ancestral; the gap character is assumed to be '?', but often this will be '-' if your data comes direct from the mapping pipe, so you will need to change to gapChar="-"

(v) Blocks file (to be passed to the function via blockFile="blocksByStrain.txt")
- note you need to specify the total size of the genome in base pairs, to set up the appropriate X-axis; set using genome_size

Tree plotting function
--
    plotTree(tree="tree.nwk",heatmapData="data.csv",infoFile="info.csv",barData="bar.csv",snpFile="alleles.csv", blockFile="blocksByStrain.txt")


Optionally, output to PDF:
--
    outputPDF="out.pdf"

(specify width in inches via w=X, specify height in inches via h=X)

OR output to PNG:

    outputPNG="out.png"

(specify width in pixels via w=X, specify height in pixels via h=X)

Spacing options
--
You can provide any or all of strain info, data to be plotted as a heatmap, data to be plotted as a bar chart, SNPs and/or blocks. 

The order will be:

[ tree | info | heatmap | barplot | SNPs/blocks]

• Relative widths of the components can be changed in the function; by default they are:


left & right spacing framing the whole page: edgeWidth = 1

tree plotting space: treeWidth = 10

info printing space: infoWidth = 10

heatmap printing space: dataWidth = 30

barplot plotting space: barDataWidth = 10

SNP/blocks plotting space: blockPlotWidth = 10

• Relative heights of the components can be changed in the function; by default they are:

height of plotting spaces: mainHeight = 100

top & bottom spacing: labelHeight = 10    

  - if heatmap provided, this will be the height of the area in which the column names are printed above the heatmap; otherwise the top edge height will be taken from edgeWidth

  - if barplot provided, this will be the height of the area in which the x-axis is printed below the barplot; otherwise the bottom edge height will be taken from edgeWidth



Tree options
--
(see ?plot.phylo in R for more info)

• tip.labels = T     turns on printing strain names at the tips

• tipLabelSize = 1     change the size of printed strain names (only relevant if tip.labels=T)

• offset=0     change the spacing between the end of the tip and the printed strain name (only relevant if tip.labels=T)

• tip.colour.cex=0.5    change the size of the coloured circles at the tips (only relevant if infoFile is provided AND colourNodesBy is specified)

• tipColours = c("blue","red","black")    specify colours to use for colouring nodes (otherwise will use rainbow(n)). RColourBrewer palettes are a good option to help with colour selection

• lwd=1.5    change the line width of tree branches

• edge.color="black"    change the colour of the tree branches

• axis=F,axisPos=3     add and position an axis for branch lengths



Info options
--
• colourNodesBy = "column name"    colour the nodes according to the discrete values in this column. additional options:

- legend=T, legend.pos="bottomleft"    plot legend of node colour values, specify location (possible values: "topleft","topright","bottomleft" or "bottomright")

- ancestral.reconstruction=T     reconstruct ancestral states for this discrete variable, results will be returned as $mat and plotted as pie graphs on the tree

• infoCex=0.8     Change the size of the printed text


Heatmap options
--
• heatmap.colours=

- if not specified, uses white -> black

- colorRampPalette is a good option, eg:

    heatmap.colours=colorRampPalette(c("white","yellow","blue"),space="rgb")(100)

- note the legend/scale will be plotted above the tree

• colLabelCex=0.8       change the size of the column labels

• cluster     Cluster matrix columns?  (Default is no clustering.)

- Set cluster=T to use default hclust clustering method ("ward.D"), or specify a different method to pass to hclust (see ?hclust for options).

- Alternatively, if you have a square matrix (i.e. strain x strain) and you want to order columns the same as rows to keep it square, set cluster="square"


Barplot options
--
• barDataCol=2     Colour for the barplot (can be numeric, 1=black, 2=red, etc; or text, "red", "black", etc)


SNP plot options
--
• genome_size     Sets the length of the x-axis that represents the length of the genome. This is REQUIRED when plotting SNPs/blocks.

• gapChar="-"     Character used to indicate gaps/unknown alleles in the SNP file (will not be counted as SNPs).

• snp_colour     Sets the colour of the lines indicating SNPs (default is red)


Block plot options
--
• genome_size     Sets the length of the x-axis that represents the length of the genome. This is REQUIRED when plotting SNPs/blocks.

• block_colour     Sets the colour of the lines indicating blocks (default is black). Blocks are drawn after SNPs, so may obscure SNPs.

• blwd     Sets the height of the lines indicating blocks (default is 5).

Ancestral trait reconstruction
--
To perform ancestral discrete trait reconstruction using ace, and plot the results as pie graphs on each node of the tree:     

(i) specify the variable in the infoFile that you want to analyse: colourNodesBy="Variable_name"

(ii) set ancestral.reconstruction = T

(iii) to change the size of the pie graphs, change pie.cex (default value is 0.5)

Outputs
--
Primary output is the rendered tree figure (in the R drawing device or in a PDF/PNG file if specified)
The plotTree() function also returns an R object with the following:

$info: infoFile input file, re-ordered as per tree

$anc: result of ancestral discrete trait reconstruction using ace

$mat: heatmap data file, with rows re-ordered as per tree and columns re-ordered as per clustering (if cluster=T)

$strain_order: order of leaves in the tree


# Examples

Basic strain info
---
v<-plotTree(tree="tree.nwk",ancestral.reconstruction=F,tip.colour.cex=1,cluster=T,tipColours=c("black","purple2","skyblue2","grey"),lwd=1,infoFile="info.csv",colourNodesBy="location",treeWidth=10,infoWidth=10,infoCols=c("name","location","year"))

Pan genome heatmap
---
v<-plotTree(tree="tree.nwk",heatmapData="pan.csv",ancestral.reconstruction=F,tip.colour.cex=1,cluster=T,tipColours=c("black","purple2","skyblue2","grey"),lwd=1,infoFile="info.csv",colourNodesBy="location",treeWidth=5,dataWidth=20,infoCols=NA)

Curated genes, coloured
---
v<-plotTree(tree="tree.nwk",heatmapData="res_genes.csv",ancestral.reconstruction=F,tip.colour.cex=1,cluster=F,heatmap.colours=c("white","grey","seagreen3","darkgreen","green","brown","tan","red","orange","pink","magenta","purple","blue","skyblue3","blue","skyblue2"),tipColours=c("black","purple2","skyblue2","grey"),lwd=1,infoFile="info.csv",colourNodesBy="location",treeWidth=10,dataWidth=10,infoCols=c("name","year"),infoWidth=8)
