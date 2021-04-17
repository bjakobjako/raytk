from typing import Optional
from raytkUtil import RaytkContext, detachTox, focusFirstCustomParameterPage, ROPInfo, IconColors

# noinspection PyUnreachableCode
if False:
	# noinspection PyUnresolvedReferences
	from _stubs import *
	from _typeAliases import *
	from devel.toolkitEditor.toolkitEditor import ToolkitEditor
	from components.opPicker.opPicker import OpPicker, PickerItem

	# noinspection PyTypeHints
	op.raytkDevelEditor = ToolkitEditor(COMP())  # type: Optional[Union[ToolkitEditor, COMP]]

	ext.opPicker = OpPicker(COMP())

	class _Par(ParCollection):
		Devel: 'BoolParamT'
	class _COMP(panelCOMP):
		par: _Par

	class _UIStatePar(ParCollection):
		Showhelp: 'BoolParamT'
		Pinopen: 'BoolParamT'

	ipar.uiState = _UIStatePar()

# columns:
#  name
#  status icon

class Palette:
	def __init__(self, ownerComp: 'COMP'):
		# noinspection PyTypeChecker
		self.ownerComp = ownerComp  # type: _COMP
		self.selItem = tdu.Dependency()  # value type _AnyItemT
		self.isOpen = tdu.Dependency(False)

	@property
	def _closeTimer(self) -> 'timerCHOP':
		# noinspection PyTypeChecker
		return self.ownerComp.op('closeTimer')

	@property
	def _develMode(self):
		return bool(self.ownerComp.par.Devel)

	@property
	def SelectedItem(self):
		return ext.opPicker.SelectedItem

	def Show(self, _=None):
		self.open()

	def open(self):
		self._resetCloseTimer()
		self.ownerComp.op('window').par.winopen.pulse()
		self._resetState()
		self.isOpen.val = True
		ipar.uiState.Pinopen = False
		ext.opPicker.Loaditems()
		ext.opPicker.FocusFilterField()
		image = RaytkContext().libraryImage()
		if image and image.par['Showshortcut'] is not None:
			image.par.Showshortcut = False

	def close(self):
		self._resetCloseTimer()
		self.ownerComp.op('window').par.winclose.pulse()
		self.isOpen.val = False
		ipar.uiState.Pinopen = False

	def resetState(self):
		self._resetCloseTimer()
		self._resetState()

	def onCloseTimerComplete(self):
		if ipar.uiState.Pinopen:
			self._resetCloseTimer()
			return
		self.close()

	def _resetCloseTimer(self):
		timer = self._closeTimer
		timer.par.initialize.pulse()
		timer.par.active = False

	def _startCloseTimer(self):
		timer = self._closeTimer
		timer.par.active = True
		timer.par.start.pulse()

	def onPanelInsideChange(self, val: bool):
		if val:
			self._resetCloseTimer()
		else:
			self._startCloseTimer()

	def _resetState(self):
		ext.opPicker.Resetstate()
		self.isOpen.val = False

	def onKeyboardShortcut(self, shortcutName: str):
		if shortcutName == 'esc':
			self.close()

	def createItem(self, item: 'PickerItem'):
		if not item:
			return
		if item.isCategory:
			# TODO: maybe expand/collapse?
			return
		template = self._getTemplate(item)
		if not template:
			self._printAndStatus(f'Unable to find template for path: {item.path}')
			return
		pane = RaytkContext().activeEditor()
		dest = pane.owner if pane else None
		if not dest:
			self._printAndStatus('Unable to find active network editor pane')
			return
		newOp = self._createROP(
			template=template,
			dest=dest,
			nodeX=pane.x,
			nodeY=pane.y,
			name=template.name + ('1' if tdu.digits(template.name) is None else ''),
		)
		ui.undo.startBlock(f'Create ROP {item.shortName}')
		ui.undo.addCallback(self._createItemDoHandler, {
			'template': template,
			'dest': dest,
			'nodeX': pane.x,
			'nodeY': pane.y,
			'name': newOp.name,
		})
		ui.undo.endBlock()
		if not ipar.uiState.Pinopen:
			self.close()

	def _createROP(self, template: 'COMP', dest: 'COMP', nodeX: int, nodeY: int, name: str):
		newOp = dest.copy(
			template,
			name=name,
		)  # type: COMP
		newOp.nodeCenterX = nodeX
		newOp.nodeCenterY = nodeY
		detachTox(newOp)
		img = newOp.op('*Definition/opImage')
		if img:
			detachTox(img)
			enableCloning = img.par.enablecloning  # type: Par
			enableCloning.expr = ''
			enableCloning.val = self._develMode
			newOp.par.opviewer.val = img
			newOp.viewer = True
		enableCloning = newOp.par.enablecloning  # type: Par
		enableCloning.expr = ''
		enableCloning.val = self._develMode
		focusFirstCustomParameterPage(newOp)
		for par in newOp.customPars:
			if par.readOnly or par.isPulse or par.isMomentary or par.isDefault:
				continue
			if par.mode in (ParMode.EXPORT, ParMode.BIND):
				continue
			if par.defaultExpr and par.defaultExpr != par.default:
				par.expr = par.defaultExpr
			else:
				par.val = par.default
		newOp.allowCooking = True
		newOp.color = IconColors.defaultBgColor
		ropInfo = ROPInfo(newOp)
		ropInfo.invokeCallback('onCreate', master=template)
		self._printAndStatus(f'Created OP: {newOp} from {template}')
		return newOp

	def _createItemDoHandler(self, isUndo: bool, info: dict):
		dest = info['dest']  # type: COMP
		name = info['name']
		if isUndo:
			print(self.ownerComp, f'undoing create OP: {info}')
			newOp = dest.op(name)
			if newOp and newOp.valid:
				try:
					newOp.destroy()
				except:
					pass
		else:
			print(self.ownerComp, f'redoing create OP: {info}')
			self._createROP(
				template=info['template'],
				dest=dest,
				nodeX=info['nodeX'],
				nodeY=info['nodeY'],
				name=name,
			)

	def _printAndStatus(self, msg):
		print(self.ownerComp, msg)
		ui.status = msg

	@staticmethod
	def _getTemplate(item: 'PickerItem'):
		if not item or not item.isOP:
			return
		path = item.path
		if not path.startswith('/raytk/'):
			return op(path)
		context = RaytkContext()
		toolkit = context.toolkit()
		if toolkit and toolkit.path == '/raytk':
			return op(path)
		if not toolkit:
			return op(path)
		return op(path.replace('/raytk/', f'/{toolkit.path}/', 1))

	def onPickItem(self, item: 'PickerItem'):
		self.createItem(item)

	def onEditItem(self, item: 'PickerItem'):
		if not item or not item.isOP:
			return
		if not hasattr(op, 'raytkDevelEditor'):
			return
		template = self._getTemplate(item)
		if template:
			op.raytkDevelEditor.EditROP(template)
