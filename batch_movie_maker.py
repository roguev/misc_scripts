#!/usr/bin/python
import os
import sys

# framerate
fr = sys.argv[1]

# file extension of the individual frames
ext = sys.argv[2]

# prefixes of the individual file sets
prefixes = sys.argv[3:]

cmd = 'ffmpeg'
opt1 = '-framerate'
opt2 = '-i'
opt3 = '-c:v libx264 -r 30 -pix_fmt yuv420p'
for prefix in prefixes:
	out_fname = "%s.mp4" % prefix
	in_fname = "%s_%s.%s" % (prefix, '%02d', ext)
	cmd_string = "%s %s %s %s %s %s %s" % (cmd, opt1, fr, opt2, in_fname, opt3, out_fname)
	os.system(cmd_string)
	
#ffmpeg -framerate 2 -i 1_1102.txt_%02d.png -c:v libx264 -r 30 -pix_fmt yuv420p 1_1102.mp4




