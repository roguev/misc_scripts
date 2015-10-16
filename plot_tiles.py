#!/usr/bin/python
import sys
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.cm as cm

# count lines in the dataset, helps pre-allocate memory and makes things A LOT faster
def countLines(filename):
    lines = 0
    fo = open(filename)
    for line in fo:
        lines += 1
    fo.close()
    return lines

# read all the data
def readData(filename, frames, nlines):
	fo = open(filename)
	# pre-allocate memory
	data = np.zeros((nlines,frames+2))
	current_line = 0
	
	# read line by line
	for line in fo.readlines():
		record = line.split("\t")
		data[current_line,:] = np.array([record[0:frames+2]])
		current_line+=1
	
	fo.close()
	# convert to float
	return data.astype(float)
	
def plotData(fig,data,frames,fname_prefix, cbar_min = 20, cbar_max = 40,pad = 200):
	xmin = min(data[:,0])
	xmax = max(data[:,0])

	ymin = min(data[:,1])
	ymax = max(data[:,1])

	for i in range(frames):
		fig.clf()
		ax = fig.gca()
		cmap = cm.coolwarm
		norm = mpl.colors.Normalize(vmin=cbar_min, vmax=cbar_max)
		sc = ax.scatter(data[:,0], data[:,1], c=data[:,i+2], norm=norm,cmap=cmap,s=.1,linewidth=0)
		ax.set_xlim(xmin - pad, xmax + pad)
		ax.set_ylim(ymin - pad, ymax + pad)
		fig.colorbar(sc)
		fname = "%s_%02d.png" % (fname_prefix,i)
		print "\tSaving %s" % fname
		fig.savefig(fname,dpi=300)
		

# parse command line parameters
frames = int(sys.argv[1])

# initialize plot
fig = plt.figure(frameon=False,figsize=(12,9))

for filename in sys.argv[2:]:
	# count lines
	nlines = countLines(filename)
	
	# read data
	print "Reading %s" % filename
	fname_prefix = filename.split("/")[-1]
	data = readData(filename,frames,nlines)
	plotData(fig,data,frames,fname_prefix)
