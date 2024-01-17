# noinspection PyUnreachableCode
if False:
	# noinspection PyUnresolvedReferences
	from _stubs import *
	from shaderPanel import ShaderPanel
	ext.shaderPanel = ShaderPanel(COMP())

def onCook(dat: DAT):
	dat.clear()
	ext.shaderPanel.fillPreparedCode(
		dat,
		codeBlocks=dat.inputs[0],
		selectedName=op('codeBlock_dropmenu').par.Value0.eval(),
		definition=dat.inputs[1],
	)
