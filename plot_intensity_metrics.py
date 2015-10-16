#!/usr/bin/python
import sys
from illuminate import InteropDataset
import matplotlib as mpl
import matplotlib.pyplot as plt
import pandas as pd

script, dataset, feature, tile = sys.argv
tile = int(tile)

myDataset = InteropDataset(dataset)
cm = myDataset.CorrectedIntensityMetrics()

df = pd.DataFrame(cm.data)
cycles = max(df['cycle'])
dft = df[df['tile'] == tile]
dfts = dft.sort('cycle')

A_line = plt.plot(range(1,cycles+1),dfts["%s_A" % feature],'k-',label = 'A')
T_line = plt.plot(range(1,cycles+1),dfts["%s_T" % feature],'g-',label = 'T')
G_line = plt.plot(range(1,cycles+1),dfts["%s_G" % feature],'b-',label = 'G')
C_line = plt.plot(range(1,cycles+1),dfts["%s_C" % feature],'r-',label = 'C')
legend = plt.legend()
plt.show()
