import itertools
from dataclasses import dataclass
from typing import List, Optional

# noinspection PyUnreachableCode
if False:
	# noinspection PyUnresolvedReferences
	from _stubs import *

@dataclass
class Conversion:
	fromTypes: List[str]
	toType: str
	expr: str
	name: Optional[str] = None
	label: Optional[str] = None

@dataclass
class Field:
	name: str
	label: Optional[str]
	type: str

@dataclass
class DataType:
	name: str
	label: str
	labelForCoord: Optional[str] = None
	isCoord: bool = False
	isContext: bool = False
	isReturn: bool = False
	returnConversion: Optional[Conversion] = None
	isVariable: bool = True
	vectorLength: Optional[int] = None
	fields: List[Field] = None
	defaultExpr: Optional[str] = None

	@property
	def returnAsType(self):
		return self.returnConversion.toType if self.returnConversion else self.name

	@property
	def returnExpr(self):
		return self.returnConversion.expr if self.returnConversion else 'val'

	@classmethod
	def scalar(cls, name, label, **kwargs):
		return cls(name, label, vectorLength=1, **kwargs)

	@classmethod
	def vector(cls, name, label, partType: str, parts: str, **kwargs):
		return cls(
			name, label,
			vectorLength=len(parts),
			fields=[
				Field(part, part.upper(), partType)
				for part in parts
			],
			**kwargs)

class _Conversions:
	adaptAsFloat = Conversion(
		name='adaptAsFloat',
		fromTypes=tdu.expand('float bool int uint vec[2-4] [biu]vec[2-4] Sdf'),
		toType='float',
		expr='adaptAsFloat(val)')
	adaptAsVec2 = Conversion(
		name='adaptAsVec2',
		fromTypes=tdu.expand('float vec[2-4]'),
		toType='vec2',
		expr='adaptAsVec2(val)')
	adaptAsVec3 = Conversion(
		name='adaptAsVec3',
		fromTypes=tdu.expand('float vec[2-4]'),
		toType='vec3',
		expr='adaptAsVec3(val)')
	adaptAsVec4 = Conversion(
		name='adaptAsVec4',
		fromTypes=tdu.expand('float bool int uint vec[2-4] [biu]vec[2-4]'),
		toType='vec4',
		expr='adaptAsVec4(val)')
	adaptAsSdf = Conversion(
		name='adaptAsSdf',
		fromTypes=['float', 'Sdf'],
		toType='Sdf',
		expr='adaptAsSdf(val)')

_allConversions = [
	_Conversions.adaptAsFloat,
	_Conversions.adaptAsVec2,
	_Conversions.adaptAsVec3,
	_Conversions.adaptAsVec4,
	_Conversions.adaptAsSdf,
]

def _createScalarAndVector(scalarName: str, vectorPrefix: str, label: str, defaultVal: str):
	return [
		DataType.scalar(
			scalarName, label, returnConversion=_Conversions.adaptAsFloat, defaultExpr=defaultVal),
		DataType.vector(
			f'{vectorPrefix}2', f'{label}Vector2', partType=scalarName, parts='xy',
			returnConversion=_Conversions.adaptAsVec4,
			defaultExpr=f'{vectorPrefix}2({defaultVal})',
		),
		DataType.vector(
			f'{vectorPrefix}3', f'{label}Vector3', partType=scalarName, parts='xyz',
			returnConversion=_Conversions.adaptAsVec4,
			defaultExpr=f'{vectorPrefix}3({defaultVal})',
		),
		DataType.vector(
			f'{vectorPrefix}4', f'{label}Vector4', partType=scalarName, parts='xyzw',
			returnConversion=_Conversions.adaptAsVec4,
			defaultExpr=f'{vectorPrefix}4({defaultVal})',
		),
	]

_allTypes = [
	DataType.scalar('float', 'Float', labelForCoord='1D', isCoord=True, isReturn=True, defaultExpr='0.'),
	DataType.vector(
		'vec2', 'Vector2', labelForCoord='2D', isCoord=True,
		partType='float', parts='xy',
		returnConversion=_Conversions.adaptAsVec4,
		defaultExpr='vec2(0.)',
	),
	DataType.vector(
		'vec3', 'Vector3', labelForCoord='3D', isCoord=True,
		partType='float', parts='xyz',
		returnConversion=_Conversions.adaptAsVec4,
		defaultExpr='vec3(0.)',
	),
	DataType.vector(
		'vec4', 'Vector', isReturn=True,
		partType='float', parts='xyzw',
		defaultExpr='vec4(0.)',
	),
]

_allTypes += _createScalarAndVector('bool', 'bvec', 'Bool', 'false')
_allTypes += _createScalarAndVector('int', 'ivec', 'Int', '0')
_allTypes += _createScalarAndVector('uint', 'uvec', 'UInt', '0')

_allTypes += [
	DataType(
		'Sdf', 'SDF', isReturn=True,
		fields=[
			Field('x', 'Distance', 'float'),
			Field('mat', 'Material', 'vec3'),
			# TODO: sdf fields
		]),
	DataType(
		'Ray', 'Ray', isReturn=True,
		fields=[
			Field('pos', 'Origin', 'vec3'),
			Field('dir', 'Direction', 'vec3'),
		]),
	DataType(
		'Light', 'Light', isReturn=True,
		fields=[
			Field('pos', 'Position', 'vec3'),
			Field('color', 'Color', 'vec3'),
		]),
	DataType(
		'Particle', 'Particle', isReturn=True,
		fields=[
			Field('pos', 'Position', 'vec3'),
			# TODO: particle fields
		]),
	DataType(
		'Context', 'Context', isContext=True, isVariable=False,
		fields=[
			# TODO: context fields
		]),
	DataType(
		'MaterialContext', 'Material Context', isContext=True, isVariable=False,
		fields=[
			# TODO: context fields
		]),
	DataType(
		'CameraContext', 'Camera Context', isContext=True, isVariable=False,
		fields=[
			# TODO: context fields
		]),
	DataType(
		'LightContext', 'Light Context', isContext=True, isVariable=False,
		fields=[
			# TODO: context fields
		]),
	DataType(
		'RayContext', 'Ray Context', isContext=True, isVariable=False,
		fields=[
			# TODO: context fields
		]),
	DataType(
		'ParticleContext', 'Particle Context', isContext=True, isVariable=False,
		fields=[
			# TODO: context fields
		]),
]

_typesByName = {
	dt.name: dt
	for dt in _allTypes
}

def _getType(name: str) -> Optional[DataType]:
	return _typesByName.get(name)

def buildCoreTypeTable(dat: 'scriptDAT'):
	dat.clear()
	dat.appendRow(['name', 'isReturnType', 'isCoordType', 'isContextType'])
	def addTypes(types: List[DataType]):
		for dt in types:
			dat.appendRow([
				dt.name, int(dt.isReturn), int(dt.isCoord), int(dt.isContext),
			])
	addTypes([
		_typesByName['float'],
		_typesByName['vec2'], _typesByName['vec3'], _typesByName['vec4'],
		_typesByName['Sdf'], _typesByName['Ray'], _typesByName['Light'], _typesByName['Particle'],
	])
	addTypes([
		dt
		for dt in _allTypes
		if dt.isContext
	])

def buildVariableTypeTable(dat: 'scriptDAT'):
	dat.clear()
	dat.appendRow(['name', 'label', 'returnAs', 'defaultExpr'])
	for dt in _allTypes:
		if not dt.isVariable:
			continue
		dat.appendRow([
			dt.name,
			dt.label,
			dt.returnAsType,
			dt.defaultExpr or '',
		])

def buildVariableTypeFieldTable(dat: 'scriptDAT'):
	dat.clear()
	dat.appendRow(['parentType', 'name', 'label', 'type', 'accessExpr', 'returnAs', 'returnExpr'])
	for dt in _allTypes:
		if not dt.isVariable:
			continue
		dat.appendRow([
			dt.name, 'this', '(value)',
			dt.name,
			'val',
			dt.returnAsType,
			dt.returnExpr,
		])
		if not dt.fields:
			continue
		for field in dt.fields:
			fieldType = _getType(field.type)
			if not fieldType or not fieldType.isReturn:
				pass
			dat.appendRow([
				dt.name, field.name, field.label,
				field.type,
				f'val.{field.name}',
				fieldType.returnAsType,
				fieldType.returnExpr,
			])

def _conversionsFrom(fromType: str):
	return [
		conv
		for conv in _allConversions
		if fromType in conv.fromTypes
	]
