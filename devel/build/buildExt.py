from datetime import datetime
from pathlib import Path
from raytkTools import RaytkTools
from raytkUtil import RaytkTags, navigateTo, focusFirstCustomParameterPage, CategoryInfo, RaytkContext, IconColors
from raytkBuild import BuildContext, DocProcessor
from typing import Callable, List, Optional, TextIO

# noinspection PyUnreachableCode
if False:
	# noinspection PyUnresolvedReferences
	from _stubs import *

class BuildManager:
	def __init__(self, ownerComp: 'COMP'):
		self.ownerComp = ownerComp
		self.logTable = ownerComp.op('log')
		self.context = None  # type: Optional[BuildContext]
		self.docProcessor = None  # type: Optional[DocProcessor]
		self.experimentalMode = False
		self.processSnippets = False
		self.logFile = None  # type: Optional[TextIO]
		self.enableVerboseLogging = False

	def OnInit(self):
		self.ClearLog()

	@staticmethod
	def GetToolkitVersion():
		return RaytkContext().toolkitVersion()

	@staticmethod
	def OpenToolkitNetwork():
		navigateTo(RaytkContext().toolkit(), name='raytkBuildNetwork', popup=True, goInto=True)

	def OpenLog(self):
		dat = self.ownerComp.op('full_log_text')
		dat.openViewer()

	def ClearLog(self):
		self.logTable.clear()
		self.closeLogFile()

	def closeLogFile(self):
		if not self.logFile:
			return
		self.logFile.close()
		self.logFile = None

	def startNewLogFile(self):
		stamp = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
		fileName = f'build/log/build-{stamp}.txt'
		filePath = Path(fileName)
		filePath.parent.mkdir(parents=True, exist_ok=True)
		self.logFile = filePath.open('a')

	def ReloadToolkit(self):
		self.logTable.clear()
		self.log('Reloading toolkit')
		toolkit = RaytkContext().toolkit()
		queueCall(self.reloadToolkit, toolkit)

	def RunBuild(self):
		self.experimentalMode = bool(self.ownerComp.op('experimental_toggle').par.Value0)
		self.enableVerboseLogging = bool(self.ownerComp.op('verboseLogging_toggle').par.Value0)
		self.processSnippets = bool(self.ownerComp.op('snippets_toggle').par.Value0)
		self.logTable.clear()
		self.closeLogFile()
		if self.ownerComp.op('useLogFile_toggle').par.Value0:
			self.startNewLogFile()
		def afterBuild():
			self.closeLogFile()
		def afterToolkitBuild():
			if self.processSnippets:
				snippetsBuilder = SnippetsBuilder(
					log=self.log,
					experimentalMode=self.experimentalMode,
					reloadSnippets=self.reloadSnippets,
				)
				snippetsBuilder.runBuild(thenRun=afterBuild)
			else:
				afterBuild()
		builder = ToolkitBuilder(
			log=self.log,
			experimentalMode=self.experimentalMode,
			reloadToolkit=self.reloadToolkit,
		)
		builder.runBuild(thenRun=afterToolkitBuild)

	@staticmethod
	def reloadToolkit(toolkit: 'COMP'):
		toolkit.par.externaltox = 'src/raytk.tox'
		toolkit.par.reinitnet.pulse()
		# Do this early since it switches off things like automatically writing to the opList.txt file.
		# See https://github.com/t3kt/raytk/issues/95
		toolkit.par.Devel = False

	@staticmethod
	def reloadSnippets(snippets: 'COMP'):
		snippets.par.externaltox = 'snippets/raytkSnippets.tox'
		snippets.par.reinitnet.pulse()
		# Do this early since it switches off things like automatically writing to the opList.txt file.
		# See https://github.com/t3kt/raytk/issues/95
		snippets.par.Devel = False

	def log(self, message: str, verbose=False):
		if verbose and not self.enableVerboseLogging:
			return
		print(message)
		if self.logFile:
			print(message, file=self.logFile)
		self.logTable.appendRow([message])

	@staticmethod
	def queueMethodCall(method: Callable, *args):
		queueCall(method, *args)

class _BuilderBase:
	def __init__(
			self,
			log: Callable,
			experimentalMode: bool,
	):
		self.experimentalMode = experimentalMode
		self.context = BuildContext(
			log,
			experimental=experimentalMode)
		self.afterBuild = None  # type: Optional[Callable]

	def runBuild(self, thenRun: Callable):
		self.afterBuild = thenRun
		pass

	def getOutputToxPath(self, baseName: str):
		version = RaytkContext().toolkitVersion()
		if self.experimentalMode:
			suffix = '-exp'
		else:
			suffix = ''
		return f'build/{baseName}-{version}{suffix}.tox'

	def finalizeRootPars(self, comp: 'COMP'):
		self.context.moveNetworkPane(comp)
		comp.par.Devel.readOnly = True
		comp.par.externaltox = ''
		comp.par.enablecloning = False
		comp.par.savebackup = True
		comp.par.reloadtoxonstart = True
		comp.par.reloadcustom = True
		comp.par.reloadbuiltin = True
		focusFirstCustomParameterPage(comp)

	def log(self, message: str, verbose=False):
		self.context.log(message, verbose)

	def logStageStart(self, desc: str):
		self.log(f'===[{desc}]===')

class ToolkitBuilder(_BuilderBase):
	def __init__(
			self,
			log: Callable,
			experimentalMode: bool,
			reloadToolkit: Callable,
	):
		super().__init__(log, experimentalMode)
		self.reloadToolkit = reloadToolkit
		self.docProcessor = None  # type: Optional[DocProcessor]
		if not self.experimentalMode:
			self.docProcessor = DocProcessor(
				self.context,
				outputFolder='docs/_reference',
				imagesFolder='docs/assets/images',
			)

	def runBuild(self, thenRun: Callable):
		super().runBuild(thenRun)
		version = RaytkContext().toolkitVersion()
		self.log('Starting build')
		self.log(f'Version: {version}' + (' (experimental)' if self.experimentalMode else ''))
		queueCall(self.runBuild_stage, 0)

	def runBuild_stage(self, stage: int):
		toolkit = RaytkContext().toolkit()
		if stage == 0:
			self.log('Reloading toolkit')
			self.reloadToolkit(toolkit)
			self.context.openNetworkPane()
			queueCall(self.runBuild_stage, stage + 1)
		elif stage == 1:
			self.logStageStart('Detach fileSync ops')
			self.context.detachAllFileSyncDatsIn(toolkit, reloadFirst=True)
			queueCall(self.runBuild_stage, stage + 1)
		elif stage == 2:
			if self.docProcessor:
				self.logStageStart('Clear old docs')
				self.docProcessor.clearPreviousDocs()
			queueCall(self.runBuild_stage, stage + 1)
		elif stage == 3:
			self.logStageStart('Process thumbnails')
			self.context.runBuildScript(
				toolkit.op('libraryThumbs/BUILD'),
				thenRun=self.runBuild_stage, runArgs=[stage + 1])
		elif stage == 4:
			self.logStageStart('Update library info')
			self.updateLibraryInfo(toolkit, thenRun=self.runBuild_stage, runArgs=[stage + 1])
		elif stage == 5:
			self.logStageStart('Update library image')
			self.updateLibraryImage(toolkit, thenRun=self.runBuild_stage, runArgs=[stage + 1])
		elif stage == 6:
			self.logStageStart('Process operators')
			self.processOperators(toolkit.op('operators'), thenRun=self.runBuild_stage, runArgs=[stage + 1])
		elif stage == 7:
			self.logStageStart('Process nested operators')
			self.processNestedOperators(toolkit.op('operators'), thenRun=self.runBuild_stage, runArgs=[stage + 1])
		elif stage == 8:
			self.logStageStart('Lock library info')
			self.lockLibraryInfo(toolkit, thenRun=self.runBuild_stage, runArgs=[stage + 1])
		elif stage == 9:
			self.logStageStart('Remove op help')
			self.removeAllOpHelp(thenRun=self.runBuild_stage, runArgs=[stage + 1])
		elif stage == 10:
			self.logStageStart('Process tools')
			self.processTools(toolkit.op('tools'), thenRun=self.runBuild_stage, runArgs=[stage + 1])
		elif stage == 11:
			self.logStageStart('Lock buildLock ops')
			self.context.lockBuildLockOps(toolkit)
			queueCall(self.runBuild_stage, stage + 1)
		elif stage == 12:
			self.logStageStart('Process components')
			self.processComponents(toolkit.op('components'), thenRun=self.runBuild_stage, runArgs=[stage + 1])
		elif stage == 13:
			self.logStageStart('Remove buildExclude ops')
			self.context.removeBuildExcludeOps(toolkit)
			queueCall(self.runBuild_stage, stage + 1)
		elif stage == 14:
			self.logStageStart('Remove redundant python mods')
			self.context.removeRedundantPythonModules(toolkit, toolkit.ops('tools', 'libraryInfo'))
			queueCall(self.runBuild_stage, stage + 1)
		elif stage == 15:
			self.logStageStart('Finalize toolkit pars')
			self.finalizeRootPars(toolkit)
			queueCall(self.runBuild_stage, stage + 1)
		elif stage == 16:
			self.logStageStart('Finish build')
			self.context.focusInNetworkPane(toolkit)
			toxFile = self.getOutputToxPath('RayTK')
			self.log(f'Exporting TOX to {toxFile}')
			toolkit.save(toxFile)
			self.log('Build completed!')
			self.log(f'Exported tox file: {toxFile}')

	def updateLibraryImage(
			self, toolkit: 'COMP',
			thenRun: 'Optional[Callable]' = None, runArgs: list = None):
		self.log('Updating library image')
		image = RaytkContext().libraryImage()
		if image:
			# self.context.moveNetworkPane(image)
			self.context.detachTox(image)
			self.context.lockBuildLockOps(image)
			image.par.Showshortcut = True
			toolkit.par.opviewer.val = image
			toolkit.par.opviewer.readOnly = True
			toolkit.viewer = True
		else:
			toolkit.par.opviewer.val = ''
			toolkit.viewer = False
		if thenRun:
			queueCall(thenRun, *(runArgs or []))

	def updateLibraryInfo(
			self, toolkit: 'COMP',
			thenRun: 'Optional[Callable]' = None, runArgs: list = None):
		self.log('Updating library info')
		if toolkit.par['Experimentalbuild'] is not None:
			toolkit.par.Experimentalbuild.val = self.experimentalMode
			toolkit.par.Experimentalbuild.readOnly = True
		libraryInfo = toolkit.op('libraryInfo')
		libraryInfo.par.Forcebuild.pulse()
		self.context.moveNetworkPane(libraryInfo)
		self.context.runBuildScript(
			libraryInfo.op('BUILD'),
			thenRun=lambda: queueCall(thenRun, *(runArgs or [])),
			runArgs=[])

	def lockLibraryInfo(
			self, toolkit: 'COMP',
			thenRun: 'Optional[Callable]' = None, runArgs: list = None):
		self.log('Locking library info')
		self.context.lockOps(toolkit.ops(
			'info', 'opTable', 'opCategoryTable', 'opHelpTable', 'buildInfo'))
		if thenRun:
			queueCall(thenRun, *(runArgs or []))

	def processComponents(
			self, components: 'COMP',
			thenRun: 'Optional[Callable]' = None, runArgs: list = None):
		self.log(f'Processing components {components}')
		self.context.focusInNetworkPane(components)
		self.context.safeDestroyOp(components)
		queueCall(thenRun, *(runArgs or []))

	def processOperators(
			self, comp: 'COMP',
			thenRun: 'Optional[Callable]' = None, runArgs: list = None):
		self.log(f'Processing operators {comp}')
		self.context.moveNetworkPane(comp)
		self.context.detachTox(comp)
		categories = RaytkContext().allCategories()
		# categories.sort(key=lambda c: c.name)
		if self.docProcessor:
			self.docProcessor.writeCategoryListPage(categories)
		queueCall(self.processOperatorCategories_stage, categories, thenRun, runArgs)

	def processOperatorCategories_stage(
			self, categories: List['COMP'],
			thenRun: 'Optional[Callable]' = None, runArgs: list = None):
		if categories:
			category = categories.pop()
			self.processOperatorCategory(
				category,
				thenRun=self.processOperatorCategories_stage,
				runArgs=[categories, thenRun, runArgs])
		elif thenRun:
			queueCall(thenRun, *(runArgs or []))

	def processOperatorCategory(
			self, category: 'COMP',
			thenRun: 'Optional[Callable]' = None, runArgs: list = None):
		categoryInfo = CategoryInfo(category)
		self.log(f'Processing operator category {category.name}')
		self.context.moveNetworkPane(category)
		self.context.detachTox(category)
		template = category.op('__template')
		if template:
			template.destroy()
		if not self.experimentalMode:
			self.context.removeAlphaOps(category)
		comps = categoryInfo.operators
		# comps.sort(key=lambda c: c.name)
		queueCall(self.processOperatorCategory_stage, category, comps, thenRun, runArgs)

	def processOperatorCategory_stage(
			self, category: 'COMP', components: List['COMP'],
			thenRun: 'Optional[Callable]' = None, runArgs: list = None):
		if components:
			comp = components.pop()
			self.processOperator(comp)
			queueCall(self.processOperatorCategory_stage, category, components, thenRun, runArgs)
		else:
			# after finishing the operators in the category, process the category help
			if self.docProcessor:
				self.docProcessor.processOpCategory(category)
			self.context.removeCatHelp(category)
			if thenRun:
				queueCall(thenRun, *(runArgs or []))

	def processOperator(self, comp: 'COMP'):
		self.log(f'Processing operator {comp}')
		self.context.focusInNetworkPane(comp)
		self.context.disableCloning(comp)
		self.context.detachTox(comp)
		tools = RaytkTools()
		tools.updateROPMetadata(comp)
		tools.updateROPParams(comp)
		self.context.applyParamUpdatersIn(comp)
		self.context.resetCustomPars(comp)
		self.context.lockROPPars(comp)

		# This really shouldn't be necessary but there's something strange with old cloned components...
		self.context.safeDestroyOp(comp.op('opDefinition/paramHelpEditor'))

		# self.context.moveNetworkPane(comp)
		self.processOperatorSubCompChildrenOf(comp)
		# self.context.moveNetworkPane(comp)
		if not comp.isPanel:
			comp.showCustomOnly = True
			self.log(f'Updating OP image for {comp}')
			img = tools.updateOPImage(comp)
			if img:
				# self.context.focusInNetworkPane(img)
				self.context.disableCloning(img)
				self.context.detachTox(img)
				self.context.lockBuildLockOps(img)
				self.context.cleanOpImage(img)
		comp.color = IconColors.defaultBgColor
		if self.docProcessor:
			self.docProcessor.processOp(comp)

	def processOperatorSubCompChildrenOf(self, comp: 'COMP'):
		subComps = comp.findChildren(type=COMP)
		if not subComps:
			return
		self.context.log(f'Processing {len(subComps)} sub-comps in {comp}', verbose=True)
		for child in subComps:
			self.processOperatorSubComp_2(child)

	def processOperatorSubComp_2(self, comp: 'COMP'):
		self.context.log(f'Processing {comp}', verbose=True)
		self.context.detachTox(comp)
		self.context.reclone(comp)
		self.context.disableCloning(comp)
		self.processOperatorSubCompChildrenOf(comp)

	def processNestedOperators(
			self, comp: 'COMP',
			thenRun: 'Optional[Callable]' = None, runArgs: list = None):
		self.log('Processing nested operators')
		subOps = comp.findChildren(tags=[RaytkTags.raytkOP.name], depth=4)
		self.log(f'found {len(subOps)} nested operators')
		queueCall(self.processNestedOperators_stage, subOps, thenRun, runArgs)

	def processNestedOperators_stage(
			self, comps: List['COMP'],
			thenRun: 'Optional[Callable]' = None, runArgs: list = None):
		if comps:
			comp = comps.pop()
			self.processNestedOperator(comp)
			if comps:
				queueCall(self.processNestedOperators_stage, comps, thenRun, runArgs)
				return
		if thenRun:
			queueCall(thenRun, *(runArgs or []))

	def processNestedOperator(self, rop: 'COMP'):
		self.log(f'Processing sub-operator {rop.path}')
		self.context.updateOrReclone(rop)
		self.context.detachTox(rop)
		self.context.disableCloning(rop)

	def removeAllOpHelp(
			self,
			thenRun: 'Optional[Callable]' = None, runArgs: list = None):
		operators = RaytkContext().allMasterOperators()
		for comp in operators:
			self.context.removeOpHelp(comp)
		queueCall(thenRun, *(runArgs or []))

	def processTools(
			self, comp: 'COMP',
			thenRun: 'Optional[Callable]' = None, runArgs: list = None):
		self.log(f'Processing tools {comp}')
		self.context.moveNetworkPane(comp)
		self.context.reloadTox(comp)
		self.context.detachTox(comp)
		self.context.runBuildScript(
			comp.op('BUILD'),
			thenRun=lambda: queueCall(thenRun, *(runArgs or [])),
			runArgs=[])

class SnippetsBuilder(_BuilderBase):
	def __init__(
			self,
			log: Callable,
			experimentalMode: bool,
			reloadSnippets: Callable,
	):
		super().__init__(log, experimentalMode)
		self.reloadSnippets = reloadSnippets

	def runBuild(self, thenRun: Callable):
		super().runBuild(thenRun)
		self.log('Starting snippets build')
		queueCall(self.runBuild_stage, 0)

	def runBuild_stage(self, stage: int):
		snippets = getattr(op, 'raytkSnippets', None)
		if not snippets:
			self.context.log('ERROR: Snippets not found!')
			raise Exception('Snippets not found!')
		if stage == 0:
			self.log('Reloading snippets root')
			self.reloadSnippets(snippets)
			queueCall(self.runBuild_stage, stage + 1)
		elif stage == 1:
			self.logStageStart('Process navigator')
			self.context.runBuildScript(snippets.op('navigator/BUILD'), thenRun=self.runBuild_stage, runArgs=[stage + 1])
		elif stage == 2:
			self.logStageStart('Process snippets structure')
			self.processSnippetsStructure(snippets)
			queueCall(self.runBuild_stage, stage + 1)
		elif stage == 3:
			self.logStageStart('Process snippets')
			self.processSnippets(snippets, thenRun=self.runBuild_stage, runArgs=[stage + 1])
		elif stage == 4:
			self.logStageStart('Remove buildExclude ops')
			self.context.removeBuildExcludeOps(snippets)
			queueCall(self.runBuild_stage, stage + 1)
		elif stage == 5:
			self.logStageStart('Finalize snippets root pars')
			self.finalizeRootPars(snippets)
			queueCall(self.runBuild_stage, stage + 1)
		elif stage == 6:
			self.logStageStart('Finish snippets build')
			self.context.focusInNetworkPane(snippets)
			toxFile = self.getOutputToxPath('RayTKSnippets')
			self.log(f'Exporting TOX to {toxFile}')
			snippets.save(toxFile)
			self.log('Build completed!')
			self.log(f'Exported tox file: {toxFile}')

	def processSnippetsStructure(self, snippets: 'COMP'):
		snippetsRoot = snippets.op('snippets')
		self.context.detachTox(snippetsRoot)
		operatorsRoot = snippets.op('snippets/operators')
		self.context.detachTox(operatorsRoot)
		for comp in operatorsRoot.children:
			if not comp.isCOMP:
				continue
			self.context.detachTox(comp)

	def processSnippets(self, snippets: 'COMP', thenRun: Callable, runArgs: list):
		self.log('Processing snippets')
		snippetsRoot = snippets.op('snippets')
		snippetTable = snippets.op('navigator/snippetTable')  # type: DAT
		opTable = RaytkContext().opTable()
		knownOpTypes = [c.val for c in opTable.col('opType')[1:]]

		self.log(f'Found {snippetTable.numRows - 1} snippets')

		def processSnippetsStage(row: int):
			if row >= snippetTable.numRows:
				queueCall(thenRun, *runArgs)
			else:
				snippetOpType = snippetTable[row, 'opType'].val
				snippet = snippetsRoot.op(snippetTable[row, 'relPath'])
				self.log(f'Processing snippet {snippet}')
				self.context.focusInNetworkPane(snippet)
				if snippetOpType not in knownOpTypes:
					self.log(f'Removing snippet for missing type {snippetOpType}')
					self.context.safeDestroyOp(snippet)
					queueCall(processSnippetsStage, row + 1)
				else:
					queueCall(self.processSnippet, snippet, processSnippetsStage, row + 1)

		queueCall(processSnippetsStage, 1)

	def processSnippet(self, snippet: 'COMP', theRun: Callable, runArgs: list):
		self.context.detachTox(snippet)

		def processSnippetStage(stage: int):
			if stage == 0:
				self.log('Enabling snippet cooking')
				snippet.allowCooking = True
			elif stage == 1:
				rops = RaytkContext().ropChildrenOf(snippet)
				self.log(f'Updating {len(rops)} ROPs')
				for rop in rops:
					self.context.updateOrReclone(rop)
			elif stage == 2:
				self.log('Disabling snippet cooking')
				snippet.allowCooking = False
			else:
				queueCall(theRun, *(runArgs or []))
				return
			queueCall(processSnippetStage, stage + 1)

		queueCall(processSnippetStage, 0)

def queueCall(action: Callable, *args):
	run('args[0](*(args[1:]))', action, *args, delayFrames=2, delayRef=root)
