#!/usr/bin/python
import sys
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

def dist2hist(a, b1, b2, binsize=1):
	nbins = (b2-b1)/binsize+1
	bins = np.linspace(b1,b2,num=nbins)
	hist = np.zeros((nbins,))
	for bn in range(len(bins)):
		hits = [x for x in a if x == bins[bn]]
		print hits
		hist[bn] = len(hits)
	return (bins,hist)

def hist2percentile(hist,p,b1,b2,binsize=1):
	nbins = (b2-b1)/binsize+1
	bins = np.linspace(b1,b2,num=nbins)
	print bins
	n = np.sum(hist)
	print n
	rank = n*p/100.
	print rank
	b = 0
	for f in hist:
		if b + f <= rank:
			b += 1
		else:
			break
	
	return bins[b] 

x = np.linspace(1,100,num=100)
print x
bins,hist = dist2hist(x,1,100)
print hist
print hist2percentile(hist,18,1,100)
