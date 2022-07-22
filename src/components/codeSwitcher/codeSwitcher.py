from typing import Dict, List, Optional

# noinspection PyUnreachableCode
if False:
	# noinspection PyUnresolvedReferences
	from _stubs import *

def _table() -> 'DAT':
	return op('table')

def _allHostPars() -> 'List[Par]':
	host = parent().par.Hostop.eval()
	if not host:
		return []
	return host.pars(*tdu.expand(parent().par.Param.eval()))

def _hostPar() -> 'Optional[Par]':
	for p in _allHostPars():
		return p

def _effectiveMode():
	mode = parent().par.Switchmode.eval()
	par = _hostPar()
	if par is not None and mode == 'auto':
		mode = 'inline'if par is None or par.readOnly else 'switch'
	return mode

def buildStateTable(dat: 'DAT'):
	dat.clear()
	dat.appendRow(['effectiveMode', _effectiveMode()])

def buildParametersTable(dat: 'DAT'):
	dat.clear()
	mode = _effectiveMode()
	params = []
	macroParams = []
	name = parent().par.Param.eval()
	if mode == 'switch':
		params.append(name)
	else:
		macroParams.append(name)
	if parent().par.Manageparamstates:
		if mode == 'switch' or parent().par.Alwaysincludeallparams:
			params += list(_paramModes().keys())
		else:
			params.append(str(op('currentItemInfo')[1, 'params'] or ''))
	dat.appendRow(['params', ' '.join(params)])
	dat.appendRow(['macroParams', ' '.join(macroParams)])

def buildParameterGroupTable(dat: 'DAT'):
	dat.clear()
	dat.appendRow(['names', 'source', 'handling', 'readOnlyHandling', 'conversion', 'enable'])
	mode = _effectiveMode()
	if mode == 'none':
		dat.appendRow([parent().par.Param, 'param', 'macro', '', '', '1'])
	else:
		dat.appendRow([parent().par.Param, 'param', 'runtime', '', '', '1'])
	if parent().par.Manageparamstates:
		if mode == 'switch' or parent().par.Alwaysincludeallparams:
			dat.appendRow([
				' '.join(_paramModes().keys()),
				'param', 'runtime', 'macro', '', '1'
			])
		else:
			dat.appendRow([
				op('currentItemInfo')[1, 'params'] or '',
				'param', 'runtime', 'macro', '', '1'
			])

def buildMacroTable(dat: 'DAT', itemInfo: 'DAT'):
	dat.clear()
	if itemInfo.numRows < 2:
		return
	val = str(itemInfo[1, 'macros'] or '')
	if not val:
		return
	for v in val.split():
		dat.appendRow(['', v, ''])

def buildCode():
	par = _hostPar()
	if par is None and not parent().par.Indexexpr:
		return ''
	mode = _effectiveMode()
	table = op('table')
	if mode == 'switch':
		return _buildRuntimeSwitch(table)
	elif mode == 'inline':
		return _prepareItemCode(table[par.eval(), 'code']) + ';'
	else:  # none
		return ''

def _prepareItemCode(code: 'Cell'):
	code = str(code or '')
	if code.endswith(';'):
		code = code[:-1]
	return code.replace(';', ';\n')

def _buildRuntimeSwitch(table: 'DAT'):
	expr = parent().par.Indexexpr or f'int(THIS_{parent().par.Param})'
	code = f'switch ({expr}) {{\n'
	for i in range(1, table.numRows):
		name = str(table[i, 'name'])
		itemCode = _prepareItemCode(table[i, 'code'])
		if not itemCode.strip():
			continue
		code += f'\tcase {i - 1}: /*{name}*/\n'
		code += f'\t\t{itemCode};\n'
		code += '\t\tbreak;\n'
	code += '}\n'
	return code

def _paramModes() -> Dict[str, List[str]]:
	table = _table()
	if table.numRows < 2:
		return {}
	paramModes = {}  # type: Dict[str, List[str]]
	for i in range(1, table.numRows):
		params = tdu.expand(table[i, 'params'].val)
		val = table[i, 'name'].val
		for param in params:
			if param in paramModes:
				paramModes[param].append(val)
			else:
				paramModes[param] = [val]
	return paramModes

def _updateParamEnableExprs():
	table = _table()
	if table.numRows < 2:
		return
	hostPar = _hostPar()
	if hostPar is None:
		return
	paramModes = _paramModes()
	allValues = set(paramModes.keys())
	host = hostPar.owner
	for param, vals in paramModes.items():
		par = host.par[param]
		if set(vals) == allValues:
			par.enableExpr = ''
			par.enable = True
		else:
			par.enableExpr = f'me.par.{hostPar.name} in {repr(tuple(vals))}'

def _updateParamMenu():
	table = _table()
	if table.numRows < 2:
		return
	names = [c.val for c in table.col('name')[1:]]
	labels = [c.val for c in table.col('label')[1:]]
	for hostPar in _allHostPars():
		hostPar.menuNames = names
		hostPar.menuLabels = labels

def updateParams():
	_updateParamMenu()
	if parent().par.Manageparamstates:
		_updateParamEnableExprs()
