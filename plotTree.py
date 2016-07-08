#!/usr/bin/env python
#
# Plot a phylogenetic tree with labelled nodes
#
# Authors - name (email)
#
# Dependencies:
#	 ete2, pyqt4
#
# Todo:
# - convert data file to txt so it is the same as the matrix (which we can't change)
# - figure out how to add legends(!)
# - why are circles not circles, ie stretched, etc?
#
# Example command on merri:
'''
module load python-gcc/2.7.5
python /vlsci/VR0082/shared/code/holtlab/plotTree.py --tree tree.nwk --info info.csv --outpdf outfile.pdf
'''
#
# Last modified - Oct 20, 2013

from argparse import (ArgumentParser, FileType)
import os, sys, re, collections, operator, math
from sets import Set
from ete2 import Tree, TreeStyle, TextFace, NodeStyle, Face, ClusterTree, ProfileFace
from ete2.treeview.faces import add_face_to_node

def parse_args():
	"Parse the input arguments, use '-h' for help"
	parser = ArgumentParser(description='Plot a phylogenetic tree with leaves labelled from a file')
	parser.add_argument('--tree', type=str, required=True, help='tree file (newick format)')
	parser.add_argument('--info', type=str, required=True, help='data file (column 1 matches leaf names, other columns contain data for labelling)')
	parser.add_argument('--info_format', type=str, required=False, help='data file format: csv (default) or tab',default='csv')
	parser.add_argument('--labels', nargs='+', type=str, required=False, help='labels to use (must match column headers in the info file)')
	parser.add_argument('--font_size', type=int, required=False, help='font size for labels (default 16)',default=16)
	parser.add_argument('--colour_nodes_by', type=str, required=False, help='label to use for colouring nodes')
	parser.add_argument('--colour_branches_by', type=str, required=False, help='variable to use for colouring branches')
	parser.add_argument('--colour_backgrounds_by', type=str, required=False, help='variable to use for colouring clade backgrounds')
	parser.add_argument('--node_size', type=int, required=False, help='size for node shapes (default 10)', default=10)
	parser.add_argument('--tags', action="store_true", required=False, help='Colour label backgrounds to indicate values')
	parser.add_argument('--colour_tags', nargs='+', type=str, required=False, help='labels to use to tag each element by colour code')
	parser.add_argument('--margin_right', type=int, required=False, help='(default 20)',default=20)
	parser.add_argument('--margin_left', type=int, required=False, help='(default 20)',default=20)
	parser.add_argument('--margin_top', type=int, required=False, help='(default 20)',default=20)
	parser.add_argument('--margin_bottom', type=int, required=False, help='(default 20)',default=20)
	parser.add_argument('--border_width', type=int, required=False, help='(default 10)',default=10)
	parser.add_argument('--line_width', type=int, required=False, help='(default 1)',default=1)
	parser.add_argument('--output', type=str, required=False, help='output file (pdf or png, type is taken from the extension, eg out.pdf)')
	parser.add_argument('--width', type=int, required=False, help='width (mm, default 200)', default=200)
	parser.add_argument('--padding', type=int, required=False, help='padding between label columns (pixels, default 20)', default=20)
	parser.add_argument('--length_scale', type=int, required=False, help='scale (pixels per branch length unit)')
	parser.add_argument('--branch_padding', type=int, required=False, help='branch (pixels between each branch, ie vertical padding)')
	parser.add_argument('--show_leaf_names', action="store_true", required=False, help='Print leaf names as well as labels')
	parser.add_argument('--branch_support_print', action="store_true", required=False, help='Print branch supports')
	parser.add_argument('--branch_support_colour', action="store_true", required=False, help='Colour branch leading to node by branch supports')
	parser.add_argument('--branch_support_percent', action="store_true", required=False, help='Branch supports expressed as percent (0-100), otherwise assume scale is 0-1')
	parser.add_argument('--branch_support_cutoff', type=int, required=False, help='Colour branches with support lower than this value')
	parser.add_argument('--no_guiding_lines', action="store_true", required=False, help='Turn off linking nodes to data with guiding lines')
	parser.add_argument('--fan', action="store_true", required=False, help='Plot tree as fan dendrogram')
	parser.add_argument('--colour_dict', type=str, required=False, help='manually specify dictionary of values -> colours')
	parser.add_argument('--print_colour_dict', action="store_true", required=False, help='Print colour dictionary for later use')
	parser.add_argument('--title', type=str, required=False, help='Title for plot')
	parser.add_argument('--data', type=str, required=False, help='Data matrix (tab delmited; header row starts with "#Names col1 col2 etc...", column 1 matches leaf names, other columns should be numerical values for plotting)')
	parser.add_argument('--data_type', type=str, required=False, help='Type of data plot ([heatmap], line_profiles, bars, cbars)',default="heatmap")
	parser.add_argument('--data_width', type=int, required=False, help='Total width of data plot for each strain (mm, default 200)',default=200)
	parser.add_argument('--data_height', type=int, required=False, help='Total height of data plot for each strain (mm, default 20)',default=20)
	parser.add_argument('--mindata', type=int, required=False, help='Minimum data value for plotting scale (-1)',default=-1)
	parser.add_argument('--maxdata', type=int, required=False, help='Maximum data value for plotting scale (1)',default=1)
	parser.add_argument('--centervalue', type=int, required=False, help='Central data value for plotting scale (0)',default=0)
	parser.add_argument('--midpoint', action="store_true", required=False, help='Midpoint root the tree')
	parser.add_argument('--outgroup', type=str, required=False, help='Outgroup to root the tree')
	parser.add_argument('--no_ladderize', action="store_true", required=False, help='Switch off ladderizing')
	parser.add_argument('--interactive', action="store_true", required=False, help='Switch on interactive view (after printing tree to file)')
	parser.add_argument('--branch_thickness', type=int, required=False, help='Increase branch thickness', default=10)
	return parser.parse_args() 


# read table; return as dictionary of dictionaries
def readtable(args, leaves):
	vars_to_store = []
	if args.labels:
		vars_to_store += args.labels
	if args.colour_nodes_by:
		vars_to_store += [args.colour_nodes_by]
	if args.colour_tags:
		vars_to_store += args.colour_tags
	if args.colour_branches_by:
		vars_to_store += [args.colour_branches_by]
	if args.colour_backgrounds_by:
		vars_to_store += [args.colour_backgrounds_by]
	print "\nReading strain info from " + args.info + " (" + args.info_format + " format)"
	print "- Storing info for variables " + ", ".join(vars_to_store)
	
	table = collections.defaultdict(dict) # key 1 = row identifier (column 1), key 2 = column identifier, value = cell entry
	f = file(args.info, "r")
	column_list = []
	column_values = {} # key = label name, value = list of all values
	leaves_encountered = []
	for line in f:
		if args.info_format == "tab":
			fields = line.rstrip().split("\t")
		else:
			fields = line.rstrip().split(",")
		if len(column_list) == 0:
			column_list = fields
		else:
			row_id = fields[0]
			if len(column_list) != len(fields):
				print "\nWARNING: " + str(len(column_list)) + " column headings, " + str(len(fields)) + " entries in row " + row_id
				print "Using delimiter " + args.info_delim + ", is this correct?"
			if row_id in leaves:
				if row_id not in leaves_encountered:
					leaves_encountered.append(row_id)
				for i in range(1,len(fields)):
					column_id = column_list[i] # col name
					if column_id in vars_to_store:
						table[row_id][column_id] = fields[i]
						if column_id not in column_values:
							column_values[column_id] = [fields[i]]
						elif fields[i] not in column_values[column_id]:
							column_values[column_id].append(fields[i])
	f.close()
	column_list.pop(0) # drop column name for row id
	if not Set(leaves).issubset(Set(leaves_encountered)):
		print "\nWARNING: the following tree tips do not have data in the info file "+ args.info + ":"
		print " " + ", ".join(Set(leaves).difference(Set(leaves_encountered)))
	else:
		print "- Found data for all leaves in the tree"
	return table, column_list, column_values
	
def getColourPalette(values, args, this_label):
	# colour palettes (modified from colorbrewer set1, expanded to 50)
	colours_50 = ["#E41A1C","#C72A35","#AB3A4E","#8F4A68","#735B81","#566B9B","#3A7BB4","#3A85A8","#3D8D96","#419584","#449D72","#48A460","#4CAD4E","#56A354","#629363","#6E8371","#7A7380","#87638F","#93539D","#A25392","#B35A77","#C4625D","#D46A42","#E57227","#F67A0D","#FF8904","#FF9E0C","#FFB314","#FFC81D","#FFDD25","#FFF12D","#F9F432","#EBD930","#DCBD2E","#CDA12C","#BF862B","#B06A29","#A9572E","#B65E46","#C3655F","#D06C78","#DE7390","#EB7AA9","#F581BE","#E585B8","#D689B1","#C78DAB","#B791A5","#A8959F","#999999"]
	simple_palette = ["Red", "DarkBlue", "Gold", "LimeGreen","Violet","MediumTurquoise","Sienna","LightCoral","LightSkyBlue","Indigo","Tan","Coral","OliveDrab","Teal"]
	
	calculatePalette = True
	if args.colour_dict:
		calculatePalette = False
		colour_dict = eval(args.colour_dict)
		for v in values:
			if v not in colour_dict:
				print "\nCouldn't find colour for " + this_label + " value: " + v
				calculatePalette = True
				
	if calculatePalette:
		nvals = len(values)
		if nvals > 14:
			if nvals > 50:
				colour_list = colours_50 + int(nvals/50) * colours_50
			else:
				colour_list = colours_50[::int(math.floor(50/nvals))] # every nth colour
		else:
			colour_list = simple_palette
		colour_dict = {} # key = value, value = colour id
		for i in range(0,nvals):
			colour_dict[values[i]] = colour_list[i]
	else:
		colour_dict = eval(args.colour_dict)
		
	return colour_dict
	
# main function
def main():
	args = parse_args()
	
	if args.data:
		print "\nReading tree from " + args.tree + " and data matrix from " + args.data
		tree = ClusterTree(args.tree, text_array=args.data)
	else:
		print "\nReading tree from " + args.tree
		tree = Tree(args.tree)	
		
	if args.midpoint:
		R = tree.get_midpoint_outgroup()
		tree.set_outgroup(R)
		print "- Applying midpoint rooting"
	elif args.outgroup:
		tree.set_outgroup( tree&args.outgroup )
		print "- Rooting using outgroup " + args.outgroup
		
	if not args.no_ladderize:
		tree.ladderize()
		print "- Ladderizing tree"

	table, column_list, column_values = readtable(args, tree.get_leaf_names())
	
	labels = []
	if args.labels:
		print "\nThese labels will be printed next to each strain:"
		for label in args.labels:
			if label in column_list:
				labels.append(label)
				print " " + label
			else:
				print "WARNING: specified label " + label + " was not found in the columns of the info file provided, " + args.info

	# set node styles
	# start by setting all to no shapes, black labels
	for n in tree.traverse():
		nstyle = NodeStyle()
		nstyle["fgcolor"] = "black"
		nstyle["size"] = 0
		n.set_style(nstyle)
	
	# add colour tags next to nodes
	if args.colour_tags:
		colour_tags = []
		print "\nThese columns will be used to generate colour tags:"
		for label in args.colour_tags:
			if label in column_list:
				colour_tags.append(label)
				print " " + label
			else:
				print "\tWARNING: specified label for colour tagging, " + label + ", was not found in the columns of the info file provided, " + args.info
				
		for i in range(0,len(colour_tags)):
			label = colour_tags[i]
			colour_dict = getColourPalette(column_values[label],args,label)
			
			print "- Adding colour tag for " + label
			
			for node in tree.get_leaves():
				this_face = Face()
				this_face.margin_left = args.padding
				node.add_face(this_face, column=0, position = "aligned")
				
				if node.name in table:
					this_label = table[node.name][label]
					this_colour = colour_dict[this_label]
				else:
					this_colour = "white"
				this_face = Face()
				this_face.background.color = this_colour
				this_face.margin_right = args.margin_right
				this_face.margin_left = args.margin_left
				this_face.margin_top = args.margin_top
				this_face.margin_bottom = args.margin_bottom
				this_face.border.width = args.border_width
				this_face.border.color="white"
				node.add_face(this_face, column=i+1, position = "aligned")
		print
	else:
		colour_tags = []
	
	# add labels as columns
	for i in range(0,len(labels)):
		
		label = labels[i]
		
		print "- Adding label " + label
		if label == args.colour_nodes_by:
			print "  also colouring nodes by these values"
		
		colour_dict = getColourPalette(column_values[label],args,label)
		
		for node in tree.get_leaves():
			if node.name in table:
				this_label = table[node.name][label]
				this_colour = colour_dict[this_label]
			else:
				this_label = ""
				this_colour = "black"

			this_face = TextFace(text=this_label, fsize = args.font_size)
			if args.tags:
				this_face.background.color = this_colour
			elif label == args.colour_nodes_by:
				this_face.fgcolor = this_colour
			this_face.margin_right = args.padding
			if i == 0:
				this_face.margin_left = args.padding
			node.add_face(this_face, column=i+len(colour_tags)+1, position = "aligned")
			
			# set leaves to coloured circles
			node.img_style["size"] = args.node_size
			if label == args.colour_nodes_by:
				node.img_style["fgcolor"] = this_colour
					
	if args.colour_branches_by or args.colour_backgrounds_by or args.branch_support_colour:
		if args.colour_branches_by:
			print "- Colouring branches by label " + args.colour_branches_by
			colour_dict_br = getColourPalette(column_values[args.colour_branches_by],args,args.colour_branches_by)
		if args.colour_backgrounds_by:
			print "- Colouring node backgrounds by label " + args.colour_backgrounds_by
			colour_dict_bg = getColourPalette(column_values[args.colour_backgrounds_by],args,args.colour_backgrounds_by)
		if args.branch_support_colour:
			print "- Colouring branches by support values"
			# colours extracted from R using rgb( colorRamp(c("white","red", "black"))(seq(0, 1, length = 100)), max = 255)
			# support_colours = {0.0:"#FFFFFF",0.01:"#FFFFFF", 0.02:"#FFF9F9", 0.03:"#FFF4F4", 0.04:"#FFEFEF", 0.05:"#FFEAEA", 0.06:"#FFE5E5", 0.07:"#FFE0E0", 0.08:"#FFDADA", 0.09:"#FFD5D5", 0.1:"#FFD0D0", 0.11:"#FFCBCB", 0.12:"#FFC6C6", 0.13:"#FFC1C1", 0.14:"#FFBCBC", 0.15:"#FFB6B6", 0.16:"#FFB1B1", 0.17:"#FFACAC", 0.18:"#FFA7A7", 0.19:"#FFA2A2", 0.2:"#FF9D9D", 0.21:"#FF9797", 0.22:"#FF9292", 0.23:"#FF8D8D", 0.24:"#FF8888", 0.25:"#FF8383", 0.26:"#FF7E7E", 0.27:"#FF7979", 0.28:"#FF7373", 0.29:"#FF6E6E", 0.3:"#FF6969", 0.31:"#FF6464", 0.32:"#FF5F5F", 0.33:"#FF5A5A", 0.34:"#FF5454", 0.35:"#FF4F4F", 0.36:"#FF4A4A", 0.37:"#FF4545", 0.38:"#FF4040", 0.39:"#FF3B3B", 0.4:"#FF3636", 0.41:"#FF3030", 0.42:"#FF2B2B", 0.43:"#FF2626", 0.44:"#FF2121", 0.45:"#FF1C1C", 0.46:"#FF1717", 0.47:"#FF1212", 0.48:"#FF0C0C", 0.49:"#FF0707", 0.5:"#FF0202", 0.51:"#FC0000", 0.52:"#F70000", 0.53:"#F20000", 0.54:"#EC0000", 0.55:"#E70000", 0.56:"#E20000", 0.57:"#DD0000", 0.58:"#D80000", 0.59:"#D30000", 0.6:"#CE0000", 0.61:"#C80000", 0.62:"#C30000", 0.63:"#BE0000", 0.64:"#B90000", 0.65:"#B40000", 0.66:"#AF0000", 0.67:"#A90000", 0.68:"#A40000", 0.69:"#9F0000", 0.7:"#9A0000", 0.71:"#950000", 0.72:"#900000", 0.73:"#8B0000", 0.74:"#850000", 0.75:"#800000", 0.76:"#7B0000", 0.77:"#760000", 0.78:"#710000", 0.79:"#6C0000", 0.8:"#670000", 0.81:"#610000", 0.82:"#5C0000", 0.83:"#570000", 0.84:"#520000", 0.85:"#4D0000", 0.86:"#480000", 0.87:"#420000", 0.88:"#3D0000", 0.89:"#380000", 0.9:"#330000", 0.91:"#2E0000", 0.92:"#290000", 0.93:"#240000", 0.94:"#1E0000", 0.95:"#190000", 0.96:"#140000", 0.97:"#0F0000", 0.98:"#0A0000", 0.99:"#050000", 1:"#000000"}
			# rgb( colorRamp(c("red", "black"))(seq(0, 1, length = 100)), max = 255))
			support_colours = {}
			
			if args.branch_support_cutoff:
				for i in range(0,args.branch_support_cutoff):
					support_colours[i] = "#FF0000"
				for i in range(args.branch_support_cutoff,101):
					support_colours[i] = "#000000"
			else:
				if args.branch_support_percent:
					support_colours = {0:"#FF0000",1:"#FF0000",2:"#FC0000",3:"#F90000",4:"#F70000",5:"#F40000",6:"#F20000",7:"#EF0000",8:"#EC0000",9:"#EA0000",10:"#E70000",11:"#E50000",12:"#E20000",13:"#E00000",14:"#DD0000",15:"#DA0000",16:"#D80000",17:"#D50000",18:"#D30000",19:"#D00000",20:"#CE0000",21:"#CB0000",22:"#C80000",23:"#C60000",24:"#C30000",25:"#C10000",26:"#BE0000",27:"#BC0000",28:"#B90000",29:"#B60000",30:"#B40000",31:"#B10000",32:"#AF0000",33:"#AC0000",34:"#AA0000",35:"#A70000",36:"#A40000",37:"#A20000",38:"#9F0000",39:"#9D0000",40:"#9A0000",41:"#970000",42:"#950000",43:"#920000",44:"#900000",45:"#8D0000",46:"#8B0000",47:"#880000",48:"#850000",49:"#830000",50:"#800000",51:"#7E0000",52:"#7B0000",53:"#790000",54:"#760000",55:"#730000",56:"#710000",57:"#6E0000",58:"#6C0000",59:"#690000",60:"#670000",61:"#640000",62:"#610000",63:"#5F0000",64:"#5C0000",65:"#5A0000",66:"#570000",67:"#540000",68:"#520000",69:"#4F0000",70:"#4D0000",71:"#4A0000",72:"#480000",73:"#450000",74:"#420000",75:"#400000",76:"#3D0000",77:"#3B0000",78:"#380000",79:"#360000",80:"#330000",81:"#300000",82:"#2E0000",83:"#2B0000",84:"#290000",85:"#260000",86:"#240000",87:"#210000",88:"#1E0000",89:"#1C0000",90:"#190000",91:"#170000",92:"#140000",93:"#120000",94:"#0F0000",95:"#0C0000",96:"#0A0000",97:"#070000",98:"#050000",99:"#020000",100:"#000000"}
				else:
					support_colours = {0.0:"#FF0000", 0.01:"#FF0000", 0.02:"#FC0000", 0.03:"#F90000", 0.04:"#F70000", 0.05:"#F40000", 0.06:"#F20000", 0.07:"#EF0000", 0.08:"#EC0000", 0.09:"#EA0000", 0.1:"#E70000", 0.11:"#E50000", 0.12:"#E20000", 0.13:"#E00000", 0.14:"#DD0000", 0.15:"#DA0000", 0.16:"#D80000", 0.17:"#D50000", 0.18:"#D30000", 0.19:"#D00000", 0.2:"#CE0000", 0.21:"#CB0000", 0.22:"#C80000", 0.23:"#C60000", 0.24:"#C30000", 0.25:"#C10000", 0.26:"#BE0000", 0.27:"#BC0000", 0.28:"#B90000", 0.29:"#B60000", 0.3:"#B40000", 0.31:"#B10000", 0.32:"#AF0000", 0.33:"#AC0000", 0.34:"#AA0000", 0.35:"#A70000", 0.36:"#A40000", 0.37:"#A20000", 0.38:"#9F0000", 0.39:"#9D0000", 0.4:"#9A0000", 0.41:"#970000", 0.42:"#950000", 0.43:"#920000", 0.44:"#900000", 0.45:"#8D0000", 0.46:"#8B0000", 0.47:"#880000", 0.48:"#850000", 0.49:"#830000", 0.5:"#800000", 0.51:"#7E0000", 0.52:"#7B0000", 0.53:"#790000", 0.54:"#760000", 0.55:"#730000", 0.56:"#710000", 0.57:"#6E0000", 0.58:"#6C0000", 0.59:"#690000", 0.6:"#670000", 0.61:"#640000", 0.62:"#610000", 0.63:"#5F0000", 0.64:"#5C0000", 0.65:"#5A0000", 0.66:"#570000", 0.67:"#540000", 0.68:"#520000", 0.69:"#4F0000", 0.7:"#4D0000", 0.71:"#4A0000", 0.72:"#480000", 0.73:"#450000", 0.74:"#420000", 0.75:"#400000", 0.76:"#3D0000", 0.77:"#3B0000", 0.78:"#380000", 0.79:"#360000", 0.8:"#330000", 0.81:"#300000", 0.82:"#2E0000", 0.83:"#2B0000", 0.84:"#290000", 0.85:"#260000", 0.86:"#240000", 0.87:"#210000", 0.88:"#1E0000", 0.89:"#1C0000", 0.9:"#190000", 0.91:"#170000", 0.92:"#140000", 0.93:"#120000", 0.94:"#0F0000", 0.95:"#0C0000", 0.96:"#0A0000", 0.97:"#070000", 0.98:"#050000", 0.99:"#020000", 1.0:"#000000"}
		for node in tree.traverse():			
			nstyle = NodeStyle()
			nstyle["size"] = 0
			if node.name in table:
				#print "Colouring individual " + node.name
				if args.colour_branches_by:
					nstyle["vt_line_color"] = colour_dict_br[table[node.name][args.colour_branches_by]] # set branch colour
					nstyle["hz_line_color"] = colour_dict_br[table[node.name][args.colour_branches_by]]
				if args.colour_backgrounds_by:
					if args.colour_branches_by in table[node.name]:
						if table[node.name][args.colour_branches_by] != "none":
							nstyle["bgcolor"] = colour_dict_bg[table[node.name][args.colour_backgrounds_by]] # set background colour
				node.set_style(nstyle)
			else:
				# internal node
				descendants = node.get_leaves()
				descendant_labels_br = []
				descendant_labels_bg = []
				for d in descendants:
					if args.colour_branches_by:
						if d.name in table:
							this_label_br = table[d.name][args.colour_branches_by]
							if this_label_br not in descendant_labels_br:
								descendant_labels_br.append(this_label_br)
						elif "none" not in descendant_labels_br:
							descendant_labels_br.append("none")
					if args.colour_backgrounds_by:
						if d.name in table:
							this_label_bg = table[d.name][args.colour_backgrounds_by]
							if this_label_bg not in descendant_labels_bg:
								descendant_labels_bg.append(this_label_bg)
						elif "none" not in descendant_labels_bg:
							descendant_labels_bg.append("none")
#				nstyle = NodeStyle()
#				nstyle["size"] = 0
				if len(descendant_labels_br) == 1 and descendant_labels_br[0] != "none":
					this_colour = colour_dict_br[descendant_labels_br[0]]
					nstyle["vt_line_color"] = this_colour # set branch colour
					nstyle["hz_line_color"] = this_colour
				elif args.branch_support_colour and not node.is_leaf():
					if int(node.support) in support_colours:
						nstyle["vt_line_color"] = support_colours[int(node.support)] # take colour from support value
						nstyle["hz_line_color"] = support_colours[int(node.support)]
					else:
						print "  WARNING support values don't make sense. Note scale is assumed to be 0-1 unless using the --branch_support_percent flag."
				if len(descendant_labels_bg) == 1 and descendant_labels_bg[0] != "none":
					this_colour = colour_dict_bg[descendant_labels_bg[0]]
					nstyle["bgcolor"] = this_colour # set background colour
				node.set_style(nstyle)
					
	if args.colour_nodes_by:
		if args.colour_nodes_by not in labels:
			print "- Colouring nodes by label " + args.colour_nodes_by
			colour_dict = getColourPalette(column_values[args.colour_nodes_by],args,args.colour_nodes_by)
			for node in tree.get_leaves():
				if node.name in table:
					this_label = table[node.name][args.colour_nodes_by]
					this_colour = colour_dict[this_label]
					if this_colour != "None":
						node.img_style["fgcolor"] = this_colour
						node.img_style["size"] = args.node_size
				

	for node in tree.traverse():
		node.img_style["hz_line_width"] = args.branch_thickness
		node.img_style["vt_line_width"] = args.branch_thickness
			
	# set tree style
	ts = TreeStyle()
	
	if args.show_leaf_names:
		ts.show_leaf_name = True
	else:
		ts.show_leaf_name = False

	if args.length_scale:
		ts.scale = args.length_scale
		
	if args.branch_padding:
		ts.branch_vertical_margin = args.branch_padding
		
	if args.branch_support_print:
		ts.show_branch_support = True
		
	if args.fan:
		ts.mode = "c"
		print "\nPrinting circular tree (--fan)"
	else:
		print "\nPrinting rectangular tree, to switch to circular use --fan"
		
	if args.title:
		title = TextFace(args.title, fsize=20)
		title.margin_left = 20
		title.margin_top = 20
		ts.title.add_face(title, column=1)
		
	if args.no_guiding_lines:
		ts.draw_guiding_lines = False
		
	if args.data:
		print "\nPrinting data matrix as " + args.data_type + " with range (" +  str(args.mindata) + "->" +  str(args.maxdata) + ";" +  str(args.centervalue) + "), height " + str(args.data_height) + ", width " + str(args.data_width)
		profileFace  = ProfileFace(min_v=args.mindata, max_v=args.maxdata, center_v=args.centervalue, width=args.data_width, height=args.data_height, style=args.data_type)
		def mylayout(node):
			if node.is_leaf():
				add_face_to_node(profileFace, node, 0, aligned=True)
		ts.layout_fn = mylayout
		
	# set root branch length to zero
	tree.dist=0
	
	# render tree
	tree.render(args.output, w=args.width, dpi=300, units="mm", tree_style=ts)
	
	print "\n FINISHED! Tree plot printed to file " + args.output
	print
	
	if args.print_colour_dict:
		print colour_dict
		if args.colour_branches_by:
			print colour_dict_br
		if args.colour_backgrounds_by:
			print colour_dict_bg
	
	if args.interactive:
		print "\nEntering interactive mode..."
		tree.show(tree_style=ts)

# call main function
if __name__ == '__main__':
	main()