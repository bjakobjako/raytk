from typing import Union
import re

# noinspection PyUnreachableCode
if False:
	# noinspection PyUnresolvedReferences
	from _stubs import *
	op.raytk = COMP()

class Version:
	pattern = re.compile(r'([0-9])+(?:\.([0-9]+))?')

	def __init__(self, majorOrString: Union[str, int] = None, minor: int = None):
		if isinstance(majorOrString, str):
			s = majorOrString  # type: str
			if minor is not None:
				raise Exception('Cannot specify both string and major/minor')
			match = Version.pattern.match(s)
			if not match:
				raise Exception(f'Invalid version string: {s!r}')
			majorPart = match.group(1)
			minorPart = match.group(2)
			major = int(majorPart)
			minor = int(minorPart) if minorPart else 0
		else:
			major = majorOrString
		if major is None:
			raise Exception('Must specify either string or `major`')
		self.major = major
		self.minor = minor or 0

	def __str__(self):
		return f'{self.major}.{self.minor}'

	def __repr__(self):
		return f'Version({self.major}, {self.minor})'


def getToolkit() -> 'COMP':
	return op.raytk

def getToolkitVersion():
	toolkit = getToolkit()
	par = toolkit.par['Raytkversion']
	return Version(str(par or '0.1'))
