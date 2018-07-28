import matplotlib.pyplot as pp 
import numpy as np 
import os
import xml.etree.ElementTree as ET

def getvalues(dict, label):
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
	# print 'processing', i
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
	luts[table-1, :] = getvalues(values, 'LUTs')
	bram[table-1, :] = getvalues(values, 'BRAM/FIFO')
	slices[table-1, :] = getvalues(values, 'Slices')
	slicereg[table-1, :] = getvalues(values, 'Slice Reg')
	dsp[table-1, :] = getvalues(values, 'DSP48A1')

fig = pp.figure(figsize=(12,8))
x = np.array(range(1,luts.shape[0]+1)) * 2 * 2 + 1 # 2x for 16bit 2x for both inputs + 1 control
print x
for i in range(3):
	pp.subplot(1,3,i+1)
	pp.plot(x, luts[:,i])
	pp.plot(x, bram[:,i])
	pp.plot(x, slices[:,i])
	pp.plot(x, slicereg[:,i])
	pp.plot(x, dsp[:,i])
	
	pp.legend(['LUTs', 'BRAM', 'Slices', 'Slice Regs', 'DSP'])
	pp.xlabel('Interface size (in bytes)')
	pp.ylabel('Resource consumed')
	pp.grid(axis='y')
	pp.xticks(x[::2])

pp.subplot(1,3,1)
pp.title("Middleware")
pp.subplot(1,3,2)
pp.title("Skeleton")
pp.subplot(1,3,3)
pp.title("HWF")
# pp.show()
pp.savefig('resources.pdf')

