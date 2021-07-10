from raytkTypes import evalSpecInOp
import re

# noinspection PyUnreachableCode
if False:
	# noinspection PyUnresolvedReferences
	from _stubs import *
	from typing import Dict, List, Optional, Union
	from raytkUtil import OpDefParsT
	from _stubs.PopDialogExt import PopDialogExt


def parentPar() -> 'Union[ParCollection, OpDefParsT]':
	return parent().par

def _host() -> 'Optional[COMP]':
	return parentPar().Hostop.eval()

def buildName():
	host = _host()
	if not host:
		return ''
	pathParts = host.path[1:].split('/')
	for i in range(len(pathParts)):
		if pathParts[i].startswith('_'):
			pathParts[i] = 'U' + pathParts[i][1:]
	name = '_'.join(pathParts)
	name = re.sub('_+', '_', name)
	if name.startswith('_'):
		name = 'o_' + name
	return 'RTK_' + name

def _evalType(category: str, supportedTypes: 'DAT', inputDefs: 'DAT'):
	return evalSpecInOp(
		spec=supportedTypes[category, 'spec'].val,
		expandedTypes=supportedTypes[category, 'types'].val,
		inputCell=inputDefs[1, category],
	)

def buildTypeTable(dat: 'scriptDAT', supportedTypes: 'DAT', inputDefs: 'DAT'):
	dat.clear()
	dat.appendRows([
		['coordType', _evalType('coordType', supportedTypes, inputDefs)],
		['returnType', _evalType('returnType', supportedTypes, inputDefs)],
		['contextType', _evalType('contextType', supportedTypes, inputDefs)],
	])

def buildInputTable(dat: 'DAT', inDats: 'List[DAT]'):
	dat.clear()
	dat.appendRow(['slot', 'inputFunc', 'name', 'path', 'coordType', 'contextType', 'returnType'])
	for i, inDat in enumerate(inDats):
		slot = f'inputName{i + 1}'
		if inDat.numRows < 2 or not inDat[1, 'name'].val:
			dat.appendRow([slot])
		else:
			dat.appendRow([
				slot,
				f'inputOp{i + 1}',
				inDat[1, 'name'],
				inDat[1, 'path'],
				inDat[1, 'coordType'],
				inDat[1, 'contextType'],
				inDat[1, 'returnType'],
			])

def buildLegacyTypeSettingsTable(dat: 'DAT', inputTable: 'DAT'):
	dat.clear()
	typeVal = parentPar().Coordtype.eval()
	if typeVal != 'useinput':
		dat.appendRow(['coordType', typeVal, '0'])
	else:
		typeVal = inputTable['inputName1', 'coordType'] or parentPar().Fallbackcoordtype
		dat.appendRow(['coordType', typeVal, '1'])
	typeVal = parentPar().Contexttype.eval()
	if typeVal != 'useinput':
		dat.appendRow(['contextType', typeVal, '0'])
	else:
		typeVal = inputTable['inputName1', 'contextType'] or parentPar().Fallbackcontexttype
		dat.appendRow(['contextType', typeVal, '1'])
	typeVal = parentPar().Returntype.eval()
	if typeVal != 'useinput':
		dat.appendRow(['returnType', typeVal, '0'])
	else:
		typeVal = inputTable['inputName1', 'returnType'] or parentPar().Fallbackreturntype
		dat.appendRow(['returnType', typeVal, '1'])

def combineInputDefinitions(
		dat: 'DAT',
		inDats: 'List[DAT]',
		defFields: 'DAT',
):
	dat.clear()
	if not inDats:
		return
	cols = defFields.col(0)
	dat.appendRow(cols)
	inDats = [d for d in inDats if d.numRows > 1]
	if not inDats:
		return
	usedNames = set()
	for d in reversed(inDats):
		insertRow = 0
		for inDatRow in range(1, d.numRows):
			name = d[inDatRow, 'name'].val
			if not name or name in usedNames:
				continue
			usedNames.add(name)
			cells = [
				d[inDatRow, col] or ''
				for col in cols
			]
			dat.appendRow(cells, insertRow)
			insertRow += 1

def processInputDefinitionTypes(dat: 'scriptDAT', supportedTypeTable: 'DAT'):
	_processInputDefTypeCategory(dat, supportedTypeTable, 'coordType')
	_processInputDefTypeCategory(dat, supportedTypeTable, 'contextType')
	_processInputDefTypeCategory(dat, supportedTypeTable, 'returnType')

def _processInputDefTypeCategory(dat: 'scriptDAT', supportedTypeTable: 'DAT', category: 'str'):
	supported = supportedTypeTable[category, 'types'].val.split(' ')
	cells = dat.col(category)
	if not cells:
		return
	errors = []
	ownName = parentPar().Name.eval()
	# TODO: consolidate this and the typeRestrictor
	for cell in cells[1:]:
		inputName = dat[cell.row, 'name']
		inputTypes = cell.val.split(' ')
		supportedInputTypes = [t for t in inputTypes if t in supported]
		if not supportedInputTypes:
			errors.append(f'No supported {category} for {inputName} ({" ".join(inputTypes)}')
		elif len(supportedInputTypes) == 1:
			cell.val = supportedInputTypes[0]
		else:
			# cell.val = ' '.join(supportedInputTypes)
			cell.val = '@' + ownName

def _getParamsOp() -> 'Optional[COMP]':
	return parentPar().Paramsop.eval() or _host()

def _getRegularParams(spec: str) -> 'List[Par]':
	host = _getParamsOp()
	if not host:
		return []
	paramNames = tdu.expand(spec.strip())
	if not paramNames:
		return []
	return [
		p
		for p in host.pars(*[pn.strip() for pn in paramNames])
		if p.isCustom and not (p.isPulse and p.name == 'Inspect')
	]

def _getSpecialParamNames():
	return tdu.expand(parentPar().Specialparams.eval())

def buildParamTable(dat: 'DAT'):
	dat.clear()
	host = _getParamsOp()
	if not host:
		return
	name = parentPar().Name.eval()
	allParamNames = [p.name for p in _getRegularParams(parentPar().Params.eval())]
	allParamNames += _getSpecialParamNames()
	dat.appendCol([(name + '_' + pn) if pn != '_' else '_' for pn in allParamNames])

def buildParamDetailTable(dat: 'DAT'):
	dat.clear()
	dat.appendRow(['tuplet', 'source', 'size', 'part1', 'part2', 'part3', 'part4', 'status', 'conversion'])
	name = parentPar().Name.eval()
	params = _getRegularParams(parentPar().Params.eval())
	anglePars = _getRegularParams(parentPar().Angleparams.eval())
	if params:
		paramsByTuplet = {}  # type: Dict[str, List[Par]]
		for par in params:
			if par.tupletName in paramsByTuplet:
				paramsByTuplet[par.tupletName].append(par)
			else:
				paramsByTuplet[par.tupletName] = [par]
		for tupletName, tupletPars in paramsByTuplet.items():
			tupletPars.sort(key=lambda p: p.vecIndex)
			row = dat.numRows
			dat.appendRow(
				[
					f'{name}_{tupletName}',
					'param',
					len(tupletPars)
				])
			isAngle = False
			for i, p in enumerate(tupletPars):
				if p in anglePars:
					isAngle = True
				dat[row, 'part' + str(i + 1)] = f'{name}_{p.name}'
			dat[row, 'status'] = 'readOnly' if _canBeReadOnlyTuplet(tupletPars) else ''
			dat[row, 'conversion'] = 'angle' if isAngle else ''

	specialNames = _getSpecialParamNames()
	if specialNames:
		parts = []
		specialIndex = 0

		def addSpecial():
			cleanParts = [p for p in parts if p != '_']
			tupletName = _getTupletName(cleanParts) or f'special{specialIndex}'
			dat.appendRow([f'{name}_{tupletName}', 'special', len(cleanParts)] + [
				f'{name}_{part}' for part in cleanParts
			])

		for specialName in specialNames:
			parts.append(specialName)
			if len(parts) == 4:
				addSpecial()
				parts.clear()
				specialIndex += 1
		if parts:
			addSpecial()

def _canBeReadOnlyTuplet(pars: 'List[Par]'):
	if not pars[0].readOnly:
		return False
	for par in pars:
		if par.mode != ParMode.CONSTANT:
			return False
	return True

def _getTupletName(parts: 'List[str]'):
	if len(parts) <= 1 or len(parts[0]) <= 1:
		return None
	prefix = parts[0][:-1]
	for part in parts[1:]:
		if not part.startswith(prefix):
			return None
	return prefix

def buildParamTupletAliases(dat: 'DAT', paramTable: 'DAT'):
	dat.clear()
	for i in range(1, paramTable.numRows):
		size = int(paramTable[i, 'size'])
		if size > 1:
			dat.appendRow([
				'#define {} vec{}({})'.format(paramTable[i, 'tuplet'].val, size, ','.join([
					paramTable[i, f'part{j + 1}'].val
					for j in range(size)
				]))
			])

_typeReplacements = {
	re.compile(r'\bCoordT\b'): 'THIS_CoordT',
	re.compile(r'\bContextT\b'): 'THIS_ContextT',
	re.compile(r'\bReturnT\b'): 'THIS_ReturnT',
}

def _getReplacements(
		inputTable: 'DAT',
		materialTable: 'DAT',
) -> 'Dict[str, str]':
	name = parentPar().Name.eval()
	repls = {
		'thismap': name,
		'THIS_': name + '_',
	}
	mat = materialTable[1, 'material']
	if mat:
		repls['THISMAT'] = str(mat)
	for i in range(inputTable.numRows):
		key = inputTable[i, 'inputFunc']
		val = inputTable[i, 'name']
		if val:
			repls[str(key)] = str(val)
	return repls

def prepareCode(
		dat: 'DAT',
		inputTable: 'DAT',
		materialTable: 'DAT',
):
	if not dat.inputs:
		dat.text = ''
		return
	dat.clear()
	repls = _getReplacements(inputTable, materialTable)
	text = _prepareText(dat.inputs[0].text, repls)
	dat.write(text)

def prepareTable(
		dat: 'DAT',
		inputTable: 'DAT',
		materialTable: 'DAT',
):
	dat.copy(dat.inputs[0])
	if dat.numRows < 1:
		return
	repls = _getReplacements(inputTable, materialTable)
	for row in dat.rows():
		for cell in row:
			cell.val = _prepareText(cell.val, repls)

def _prepareText(
		text: str,
		repls: 'Dict[str, str]',
) -> str:
	if not text:
		return ''
	for find, repl in _typeReplacements.items():
		text = find.sub(repl, text)
	for find, repl in repls.items():
		text = text.replace(find, repl)
	return text

def updateLibraryMenuPar(libsComp: 'COMP'):
	p = parentPar().Librarynames  # type: Par
	libs = libsComp.findChildren(type=DAT, maxDepth=1, tags=['library'])
	libs.sort(key=lambda l: -l.nodeY)
	p.menuNames = [lib.name for lib in libs]

def prepareMacroTable(dat: 'scriptDAT', inputTable: 'DAT', macroParamTable: 'DAT'):
	dat.clear()
	for cell in inputTable.col('inputFunc')[1:]:
		if not cell.val:
			continue
		dat.appendRow([
			'',
			f'THIS_HAS_INPUT_{tdu.digits(cell.val)}',
			'',
		])
	for row in range(1, macroParamTable.numRows):
		name = macroParamTable[row, 'name']
		val = macroParamTable[row, 'value']
		style = macroParamTable[row, 'style']
		if style in ('Menu', 'Str', 'StrMenu'):
			dat.appendRow(['', f'THIS_{name}_{val}', ''])
			dat.appendRow(['', f'THIS_{name}', val])
		elif style == 'Toggle':
			if val:
				dat.appendRow(['', f'THIS_{name}', ''])
		else:
			dat.appendRow(['', f'THIS_{name}', val])
	for table in [op(parentPar().Macrotable)] + parentPar().Generatedmacrotables.evalOPs():
		if not table or table.numCols == 0 or table.numRows == 0:
			continue
		elif table.numCols == 3:
			dat.appendRows(table.rows())
		elif table.numCols == 1:
			dat.appendRows([
				['', c.val, '']
				for c in table.col(0)
			])
		elif table.numCols == 2:
			dat.appendRows([
				['', cells[0], cells[1]]
				for cells in table.rows()
			])
		else:
			dat.appendRows([
				[cells[0], cells[1], ' '.join([c.val for c in cells[2:]])]
				for cells in table.rows()
			])

def prepareTextureTable(dat: 'scriptDAT'):
	dat.clear()
	dat.appendRow(['name', 'path', 'type'])
	table = parentPar().Texturetable.eval()
	if not table or table.numRows < 1:
		return
	namePrefix = parentPar().Name.eval() + '_'
	i = 0
	useNames = False
	if table[0, 0] == 'name' and table[0, 1] == 'path':
		i = 1
		useNames = True
	while i < table.numRows:
		name = str(table[i, 'name' if useNames else 0] or '')
		path = str(table[i, 'path' if useNames else 1] or '')
		if name and path:
			dat.appendRow([
				namePrefix + name,
				path,
				table[i, 'type' if useNames else 2] or '2d',
			])
		i += 1

def prepareBufferTable(dat: 'scriptDAT'):
	dat.clear()
	dat.appendRow(['name', 'type', 'chop', 'uniformType', 'length', 'expr1', 'expr2', 'expr3', 'expr4'])
	table = parentPar().Buffertable.eval()
	if not table or table.numRows == 0:
		return
	namePrefix = parentPar().Name.eval() + '_'
	if table[0, 0] == 'name':
		for i in range(1, table.numRows):
			name = str(table[i, 'name'] or '')
			path = str(table[i, 'chop'] or '')
			expr1 = str(table[i, 'expr1'] or '')
			expr2 = str(table[i, 'expr2'] or '')
			expr3 = str(table[i, 'expr3'] or '')
			expr4 = str(table[i, 'expr4'] or '')
			if not name:
				continue
			if not path and not expr1 and not expr2 and not expr3 and not expr4:
				continue
			dat.appendRow([
				namePrefix + name,
				str(table[i, 'type'] or '') or 'vec4',
				path,
				str(table[i, 'uniformType'] or '') or 'uniformarray',
				table[i, 'length'],
				expr1, expr2, expr2, expr3,
			])
	else:
		for i in range(table.numRows):
			name = str(table[i, 0] or '')
			path = str(table[i, 1] or '')
			if not name or not path:
				continue
			dat.appendRow([
				namePrefix + name,
				str(table[i, 1] or '') or 'vec4',
				path,
				str(table[i, 2] or '') or 'uniformarray',
			])

def prepareMaterialTable(dat: 'scriptDAT'):
	dat.clear()
	dat.appendRow(['material', 'materialCode'])
	if parentPar().Materialcode:
		dat.appendRow([
			'MAT_' + parentPar().Name.eval(),
			parent().path + '/materialCode',
		])

def _isMaster():
	host = _host()
	return host and host.par.clone == host

def onValidationChange(dat: 'DAT'):
	if _isMaster():
		return
	host = _host()
	if not host:
		return
	host.clearScriptErrors()
	if dat.numRows < 2:
		return
	cells = dat.col('message')
	if not cells:
		return
	err = '\n'.join([c.val for c in cells])
	host.addScriptError(err)

def onHostNameChange():
	# Workaround for dependency update issue (#295) when the host is renamed.
	op('sel_funcTemplate').cook(force=True)

def _popDialog() -> 'PopDialogExt':
	# noinspection PyUnresolvedReferences
	return op.TDResources.op('popDialog')

def inspect(rop: 'COMP'):
	if hasattr(op, 'raytk'):
		inspector = op.raytk.op('tools/inspector')
		if inspector and hasattr(inspector, 'Inspect'):
			inspector.Inspect(rop)
			return
	_popDialog().Open(
		title='Warning',
		text='The RayTK inspector is only available when the main toolkit tox has been loaded.',
		escOnClickAway=True,
	)

def _useLocalHelp():
	return hasattr(op, 'raytk') and bool(op.raytk.par['Devel'])

def launchHelp():
	url = parentPar().Helpurl.eval()
	if not url:
		return
	if _useLocalHelp():
		url = url.replace('https://t3kt.github.io/raytk/', 'http://localhost:4000/raytk/')
	url += '?utm_source=raytkLaunch'
	ui.viewFile(url)

def updateOP():
	if not hasattr(op, 'raytk'):
		_popDialog().Open(
			title='Warning',
			text='Unable to update OP because RayTK toolkit is not available.',
			escOnClickAway=True,
		)
		return
	host = _host()
	if not host:
		return
	toolkit = op.raytk
	updater = toolkit.op('tools/updater')
	if updater and hasattr(updater, 'UpdateOP'):
		updater.UpdateOP(host)
		return
	if not host.par.clone:
		_popDialog().Open(
			title='Warning',
			text='Unable to update OP because master is not found in the loaded toolkit.',
			escOnClickAway=True,
		)
		return
	if host and host.par.clone:
		host.par.enablecloningpulse.pulse()
