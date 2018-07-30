import matplotlib.pyplot as pp 
import numpy as np 
import os
import xml.etree.ElementTree as ET
from matplotlib.ticker import MultipleLocator, FormatStrFormatter, FixedLocator

def getvalues(dict, table, label):
	return values[table]['mw'][label][1], values[table]['ul'][label][0], values[table]['mm'][label][0]

def processNode(node, dictionary):
	if node.attrib['stringID'] == "MAP_MODULE":
		key = node.attrib['value']
		dictionary[key] = dict()
		# print key
		for item in node:
			if len(item.attrib) == 5:
				label = item.attrib["label"]

				currentvalues[key][label] = (item.attrib['value'], item.attrib['ACCUMULATED'])	

			if item.attrib['label'] == "Module Name":
				# for sub in item:
				processNode(item, dictionary)

values = dict()
currentvalues = dict()
key = None

for i in range(1, 18):
	print 'processing', 'reports/{}.xrpt'.format(i)
	tree = ET.parse('reports/{}.xrpt'.format(i))
	root = tree.getroot()

	for app in root:
		for section in app:
			if section.attrib["stringID"] == "MAP_PACK_REPORT":
				for section_ in section:
					# print section_.attrib
					if section_.attrib["stringID"] == "MAP_MODULE_UTILIZATION":
						for tree_ in section_:
							for node in tree_:
								processNode(node, currentvalues)

	# print currentvalues
	values[i] = dict(currentvalues)


luts = np.zeros((len(values.keys()), 3))
bram = np.zeros((len(values.keys()), 3))
slices = np.zeros((len(values.keys()), 3))
slicereg = np.zeros((len(values.keys()), 3))
dsp = np.zeros((len(values.keys()), 3))

# 0 mw 1 skeleton 2 hwf
# print values[1]
for table in values:
	luts[table-1, :] = getvalues(values, table, 'LUTs')
	bram[table-1, :] = getvalues(values, table, 'BRAM/FIFO')
	slices[table-1, :] = getvalues(values, table, 'Slices')
	slicereg[table-1, :] = getvalues(values, table, 'Slice Reg')
	dsp[table-1, :] = getvalues(values, table, 'DSP48A1')


# print luts[14]
# print slices[14]
# print slicereg[14]
# print dsp[14]

# scale to relative consumption
luts /= 5720. / 100.
bram /= 64. / 100.
slices /= 1430. / 100.
slicereg /= 11440. / 100.
dsp /= 16. / 100.

print slicereg[-1, :]

# fig = pp.figure(figsize=(8,3))
# x = np.array(range(1,luts.shape[0]+1)) * 2 * 2 + 1 # 2x for 16bit 2x for both inputs + 1 control
x = np.array(range(1, luts.shape[0] + 1))
 # print x

fsize = (6,1.8)
majorLocator = FixedLocator(range(1, len(x), 5)) # MultipleLocator(5)
majorFormatter = FormatStrFormatter('%d')
yFormatter = FormatStrFormatter('%3d')
minorLocator = MultipleLocator(1)

fig, ax = pp.subplots(figsize=fsize) #3,1,1)
pp.plot(x, luts, 'x-')
pp.ylabel("Resource %");
ax.xaxis.set_major_locator(majorLocator)
ax.xaxis.set_major_formatter(majorFormatter)
ax.xaxis.set_minor_locator(minorLocator)
ax.yaxis.set_major_formatter(yFormatter)
pp.ylim([0, 15])
pp.title("LUTs")
pp.legend(['Middleware', 'Skeleton', 'HWF'])
pp.savefig('../../hpca2019/images/luts.pdf')

# pp.subplot(312)
fig, ax = pp.subplots(figsize=fsize) #3,1,1)
pp.plot(x, slicereg, 'x-')
pp.ylim([0, 6])
pp.title("Slice registers")
pp.ylabel("Resource %");
ax.xaxis.set_major_locator(majorLocator)
ax.xaxis.set_major_formatter(majorFormatter)
ax.xaxis.set_minor_locator(minorLocator)
ax.yaxis.set_major_formatter(yFormatter)
pp.legend(['Middleware', 'Skeleton', 'HWF'])
pp.savefig('../../hpca2019/images/slicereg.pdf')

fig, ax = pp.subplots(figsize=fsize) #3,1,1)
pp.plot(x, dsp, 'x-')
pp.title("DSP")
pp.ylim([0, 105])
pp.ylabel("Resource %");
ax.xaxis.set_major_locator(majorLocator)
ax.xaxis.set_major_formatter(majorFormatter)
ax.xaxis.set_minor_locator(minorLocator)
ax.yaxis.set_major_formatter(yFormatter)
pp.legend(['Middleware', 'Skeleton', 'HWF'])
pp.savefig('../../hpca2019/images/dsp.pdf')


# pp.legend(['Middleware', 'Skeleton', 'HWF'], bbox_to_anchor=(1,1), loc=2)

pp.show()

# mw, skel, hwf split
# for i in range(3):
# 	pp.subplot(1,3,i+1)
# 	pp.plot(x, luts[:,i])
# 	pp.plot(x, bram[:,i])
# 	# pp.plot(x, slices[:,i])
# 	pp.plot(x, slicereg[:,i])
# 	pp.plot(x, dsp[:,i])
	
# 	pp.legend(['LUTs', 'BRAM', 'Slice Regs', 'DSP']) # 'Slices', 
# 	pp.xlabel('Interface size (in bytes)')
# 	pp.ylabel('Resource consumed')
# 	pp.ylim([0, 100])
# 	pp.grid(axis='y')
# 	pp.xticks(x[::2])
# 	pp.yticks(range(0, 100, 10))

# pp.subplot(1,3,1)
# pp.title("Middleware")
# pp.subplot(1,3,2)
# pp.title("Skeleton")
# pp.subplot(1,3,3)
# pp.title("HWF")
# pp.show()


