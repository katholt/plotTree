# read  data and convert to data frame
readMatrix<-function(heatmapData){
if (is.matrix(heatmapData)) {
x = data.frame(heatmapData)
}
else if (is.data.frame(heatmapData)) {
x = heatmapData
}
else {
x<-read.csv(heatmapData,row.names=1)
}
x
}

getLayout<-function(infoFile,infoCols,heatmapData,barData,doBlocks,treeWidth=10,infoWidth=10,dataWidth=30,edgeWidth=1,labelHeight=10,mainHeight=100,barDataWidth=10,blockPlotWidth=10) {

# m = layout matrix
# w = layout widths vector
# h = layout height vector

# tree
w = c(edgeWidth,treeWidth)
m<-cbind(c(0,0,0),c(0,1,0)) # first two columns, edge + tree
x = 1

# info
if (!is.null(infoFile)) { # info is provided

printCols = TRUE
if (!is.null(infoCols)) {
if (is.na(infoCols)) {
printCols = FALSE
}}

if (printCols) {
x = x + 1
m<-cbind(m,c(0,x,0))
w = c(w,infoWidth)
}
}

# heatmap
if (!is.null(heatmapData)) { 
x = x + 1
m<-cbind(m,c(x+1,x,0)) # add heatmap & labels
x = x + 2
m[1,2] = x # add heatmap scale above tree
w = c(w,dataWidth)
}

# barplot
if (!is.null(barData)) { 
x = x + 1
m<-cbind(m,c(0,x,x+1)) # barplot and scale bar
x = x + 1
w = c(w,barDataWidth)
}

if (doBlocks) {
x = x + 1
m<-cbind(m,c(0,x,0)) # recomb blocks
w = c(w,blockPlotWidth)
}

# empty edge column
m<-cbind(m,c(0,0,0))
w = c(w,edgeWidth)

if (!is.null(heatmapData) | !is.null(barData)) { h = c(labelHeight,mainHeight,labelHeight) }
else { h = c(edgeWidth,mainHeight,edgeWidth) }

return(list(m=as.matrix(m),w=w,h=h))
}


plotTree<-function(tree,ladderise=NULL,heatmapData=NULL,barData=NULL,infoFile=NULL,blockFile=NULL,snpFile=NULL,gapChar="?",genome_size=5E6,blwd=5,block_colour="black",snp_colour="red",genome_offset=0,colourNodesBy=NULL,infoCols=NULL,outputPDF=NULL,outputPNG=NULL,w,h,heatmap.colours=rev(gray(seq(0,1,0.1))),tip.labels=F,tipLabelSize=1,offset=0,tip.colour.cex=0.5,legend=T,legend.pos="bottomleft",ancestral.reconstruction=F,cluster=NULL,tipColours=NULL,lwd=1.5,axis=F,axisPos=3,edge.color="black",infoCex=0.8,colLabelCex=0.8,treeWidth=10,infoWidth=10,dataWidth=30,edgeWidth=1,labelHeight=10,mainHeight=100,barDataWidth=10,blockPlotWidth=10,barDataCol=2,heatmapBreaks=NULL,heatmapDecimalPlaces=1,vlines.heatmap=NULL,vlines.heatmap.col=2,heatmap.blocks=NULL,pie.cex=0.5) {

require(ape)

# PREPARE TREE, CHOOSE LADDERISATION OR NOT, AND GET TIP ORDER
if (is.character(tree)){
t<-read.tree(tree)
}
else t<-tree
if (is.null(ladderise))
{
tl<-t
}
else if (ladderise=="descending")
{
tl<-ladderize(t, T)
}
else if (ladderise=="ascending")
{
tl<-ladderize(t, F)
}
else if (!is.null(ladderise))
{
print("Ladderise option should be exactly 'ascending' or 'descending'.  Any other command will raise this error. Leave option empty to order branches as per input tree.")
}
tips<-tl$edge[,2]
tip.order<-tips[tips<=length(tl$tip.label)]
tip.label.order<-tl$tip.label[tip.order] # for ordering data. note that for tiplabel(), the order is the same as in t$tip (= tl$tip)


# PREPARE HEATMAP DATA
if (!is.null(heatmapData)) {

# read heatmap data and convert to data frame
x<-readMatrix(heatmapData)

# order rows of heatmap matrix to match tree
y.ordered<-x[tip.label.order,]

# reorder columns?
if (!is.null(cluster)) {
if (!(cluster==FALSE)) {

if (cluster=="square" & ncol(y.ordered)==nrow(y.ordered)) {
# order columns to match row order
original_order<-1:nrow(x)
names(original_order)<-rownames(x)
reordered<-original_order[tip.label.order]
y.ordered<-y.ordered[,rev(as.numeric(reordered))]
}

else {
# cluster columns
if (cluster==TRUE) {cluster="ward.D2"} # set default clustering algorithm
h<-hclust(dist(t(na.omit(y.ordered))),cluster)
y.ordered<-y.ordered[,h$order]
}

}} # finished reordering columns

} # finished setting up heatmap data


# PREPARE BAR PLOT
if (!is.null(barData)) {
b<-readMatrix(barData)
barData<-b[,1]
names(barData)<-rownames(b)
}

# PREPARE INFO TO PRINT
if (!is.null(infoFile)) {
info<-readMatrix(infoFile)
info.ordered<-info[rev(tip.label.order),]
}
else {info.ordered=NULL}


# PREPARE DISCRETE TRAIT FOR COLOURING NODES AND INFERRING ANCESTRAL STATES
ancestral=NULL
nodeColourSuccess=NULL
if (!is.null(colourNodesBy) & !is.null(infoFile)) {

if (colourNodesBy %in% colnames(info.ordered)) {
nodeColourSuccess = TRUE
loc1<-info.ordered[,which(colnames(info.ordered)==colourNodesBy)]

# assign values
tipLabelSet <- character(length(loc1))
names(tipLabelSet) <- rownames(info.ordered)
groups<-table(loc1,exclude="")
n<-length(groups)
groupNames<-names(groups)

# set colours
if (is.null(tipColours)){ colours<-rainbow(n) }
else{ colours<-tipColours }

# assign colours based on values
for (i in 1:n) {
g<-groupNames[i]
tipLabelSet[loc1==g]<-colours[i]
}
tipLabelSet <- tipLabelSet[tl$tip]

# ancestral reconstruction
if (ancestral.reconstruction) { ancestral<-ace(loc1,tl,type="discrete") }

}}
# finished with trait labels and ancestral reconstruction


# OPEN EXTERNAL DEVICE FOR DRAWING
# open PDF for drawing
if (!is.null(outputPDF)) {
pdf(width=w,height=h,file=outputPDF)
}
# open PNG for drawing
if (!is.null(outputPNG)) {
png(width=w,height=h,file=outputPNG)
}


# SET UP LAYOUT FOR PLOTTING
doBlocks <- (!is.null(blockFile) | !is.null(snpFile))
l <- getLayout(infoFile,infoCols,heatmapData,barData,doBlocks,treeWidth=treeWidth,infoWidth=infoWidth,dataWidth=dataWidth,edgeWidth=edgeWidth,labelHeight=labelHeight,mainHeight=mainHeight,barDataWidth=barDataWidth,blockPlotWidth=blockPlotWidth)
layout(l$m, widths=l$w, heights=l$h)


# PLOT TREE
par(mar=rep(0,4))
tlp<-plot.phylo(tl,no.margin=T,show.tip.label=tip.labels,label.offset=offset,edge.width=lwd,edge.color=edge.color,xaxs="i", yaxs="i", y.lim=c(0.5,length(tl$tip)+0.5),cex=tipLabelSize)

# colour by trait
if (!is.null(nodeColourSuccess)) { 
tiplabels(col= tipLabelSet,pch=16,cex=tip.colour.cex) 
if (ancestral.reconstruction) { nodelabels(pie=ancestral$lik.anc, cex=pie.cex, piecol=colours) }
if (legend) { legend(legend.pos,legend=groupNames,fill=colours) }
}

if (axis) { axisPhylo(axisPos) }

# PLOT INFO
if (!is.null(infoFile)) { # info is provided

printCols = TRUE
if (!is.null(infoCols)) {
if (is.na(infoCols)) {
printCols = FALSE
}}

if (printCols) { 

par(mar=rep(0,4))

if (!is.null(infoCols)) {infoColNumbers = which(colnames(info.ordered) %in% infoCols)}
else { infoColNumbers = 1:ncol(info.ordered)}

plot(NA,axes=F,pch="",xlim=c(0,length(infoColNumbers)+1.5),ylim=c(0.5,length(tl$tip)+0.5),xaxs="i",yaxs="i")

# plot all info columns
for (i in 1:length(infoColNumbers)) {
j<-infoColNumbers[i]
text(x=rep(i+1,nrow(info.ordered)+1),y=c((nrow(info.ordered)):1),info.ordered[,j],cex=infoCex)
}

}
}


# PLOT HEATMAP
if (!is.null(heatmapData)) {

if (is.null(heatmapBreaks)) { heatmapBreaks = seq(min(y.ordered,na.rm=T),max(y.ordered,na.rm=T),length.out=length(heatmap.colours)+1) }

# plot heatmap
par(mar=rep(0,4), xpd=TRUE)
image((1:ncol(y.ordered))-0.5,(1:nrow(y.ordered))-0.5, as.matrix(t(y.ordered)),col=heatmap.colours,breaks=heatmapBreaks,axes=F,xaxs="i", yaxs="i", xlab="",ylab="")

# draw vertical lines over heatmap
if (!is.null(vlines.heatmap)) {
for (v in vlines.heatmap) {abline(v=v, col=vlines.heatmap.col)}
}

# overlay blocks on heatmap
if (!is.null(heatmap.blocks)) {
for (coords in heatmap.blocks) {rect(xleft=coords[1], 0, coords[2], ncol(y.ordered), col=vlines.heatmap.col, border=NA)}
}


# data labels for heatmap
par(mar=rep(0,4))
plot(NA, axes=F, xaxs="i", yaxs="i", ylim=c(0,2), xlim=c(0.5,ncol(y.ordered)+0.5))
text(1:ncol(y.ordered)-0.5,rep(0,ncol(x)),colnames(y.ordered), srt=90, cex=colLabelCex, pos=4)

# scale for heatmap
par(mar=c(2,0,0,2))
#image(as.matrix(seq(min(y.ordered,na.rm=T),max(y.ordered,na.rm=T),length.out=length(heatmap.colours)+1)),col=heatmap.colours,yaxt="n",xlim=c(min(y.ordered,na.rm=T),max(y.ordered,na.rm=T)))
image(as.matrix(seq(min(y.ordered,na.rm=T),max(y.ordered,na.rm=T),length.out=length(heatmap.colours)+1)),col=heatmap.colours,yaxt="n",breaks=heatmapBreaks,axes=F)
axis(1,at=heatmapBreaks[-length(heatmapBreaks)]/max(y.ordered,na.rm=T),labels=round(heatmapBreaks[-length(heatmapBreaks)],heatmapDecimalPlaces))
}

# BARPLOT
if (!is.null(barData)) {
par(mar=rep(0,4))
barplot(barData[tip.label.order], horiz=T, axes=F, xaxs="i", yaxs="i", xlab="", ylab="", ylim=c(0.25,length(barData)+0.25),xlim=c((-1)*max(barData,na.rm=T)/20,max(barData,na.rm=T)),col=barDataCol,border=0,width=0.5,space=1,names.arg=NA)

# scale for barData plot
par(mar=c(2,0,0,0))
plot(NA, yaxt="n", xaxs="i", yaxs="i", xlab="", ylab="", ylim=c(0,2), xlim=c((-1)*max(barData,na.rm=T)/20,max(barData,na.rm=T)),frame.plot=F)
}

# SNPS AND RECOMBINATION BLOCKS
if (doBlocks) {
par(mar=rep(0,4))
plot(NA,axes=F,pch="",xlim=c(genome_offset,genome_offset+genome_size+1.5),ylim=c(0.5,length(tl$tip)+0.5),xaxs="i",yaxs="i") # blank plotting area

# plot snps
if (!is.null(snpFile)) {
snps<-read.csv(snpFile,header=F,row.names=1) # in case colnames start with numbers or contain dashes, which R does not like as column headers
snps_strainCols <- snps[1,] # column names = strain names
snps<-snps[-1,] # drop strain names

for (strain in tip.label.order){
# print SNPs compared to ancestral alleles in column 1
s<-rownames(snps)[(as.character(snps[,1]) != as.character(snps[,which(snps_strainCols==strain)])) & (as.character(snps[,which(snps_strainCols==strain)])!=gapChar) & (as.character(snps[,1])!=gapChar)]
y <- which(tip.label.order==strain)
if (length(s)>0) {
for (x in s) {
points(x,y,pch="|",col=snp_colour,cex=0.25)
}
}
}
}

# plot blocks
if (!is.null(blockFile)){
blocks<-read.delim(blockFile,header=F)
for (i in 1:nrow(blocks)) {
if (as.character(blocks[i,1]) %in% tip.label.order) {
y <- which(tip.label.order==as.character(blocks[i,1]))
x1 <- blocks[i,2]
x2 <- blocks[i,3]
lines(c(x1,x2),c(y,y),lwd=blwd,lend=2,col=block_colour)
}
}
}

} # finished with SNPs and recomb blocks

# CLOSE EXTERNAL DRAWING DEVICE
if (!is.null(outputPDF) | !is.null(outputPNG)) {
dev.off()
}

# RETURN ordered info and ancestral reconstruction object
if (!is.null(heatmapData)){mat=as.matrix(t(y.ordered))}
else {mat=NULL}
return(list(info=info.ordered,anc=ancestral,mat=mat,strain_order=tip.label.order))
}
