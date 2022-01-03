# noinspection PyUnreachableCode
if False:
	# noinspection PyUnresolvedReferences
	from _stubs import *

def onCook(dat: 'DAT'):
	switcherCode = dat.inputs[0].text
	paramTable = dat.inputs[1]  # type: DAT
	effectiveMode = str(dat.inputs[2]['effectiveMode', 1])
	config = parent()
	dat.clear()
	if switcherCode.strip() in ('', ';'):
		dat.write(' ')
		return

	periodParam = config.par.Periodparam
	phaseParam = config.par.Phaseparam
	periodField = config.par.Periodfield
	phaseField = config.par.Phasefield
	isInline = effectiveMode == 'inline'

	if isInline:
		usedParams = tdu.split(paramTable['params', 1])
		needPeriod = periodParam in usedParams
		needPhase = phaseParam in usedParams
	else:
		needPeriod = True
		needPhase = True

	lines = []

	if needPeriod:
		lines += [
			f'float period = THIS_{periodParam};',
		]
		if periodField:
			lines += [
				f'#ifdef THIS_HAS_INPUT_{periodField}',
				f'period *= inputOp_{periodField}(p, ctx);',
				'#endif'
			]
	if needPhase:
		lines += [
			f'float phase = THIS_{phaseParam};'
		]
		if phaseField:
			lines += [
				f'#ifdef THIS_HAS_INPUT_{phaseField}',
				f'phase += inputOp_{phaseField}(p, ctx);',
				'#endif',
			]
	lines += [
		'q = (q / period) + phase;',
		switcherCode,
	]

	dat.write('\n'.join('\t' + line for line in lines))
