# noinspection PyUnreachableCode
if False:
	# noinspection PyUnresolvedReferences
	from _stubs import *

def onCook(dat):
	dat.clear()
	source = parent().par.Source.eval()
	if not source:
		dat.appendRow(['', ''])
		return
	varTable = source.op('opDefinition/variable_table')  # type: DAT
	if not varTable or varTable.numRows < 2:
		dat.appendRow(['', ''])
		return
	for i in range(1, varTable.numRows):
		name = varTable[i, 'localName']
		label = varTable[i, 'label']
		dataType = varTable[i, 'dataType']
		dat.appendRow([name, f'{label} ({dataType})'])
