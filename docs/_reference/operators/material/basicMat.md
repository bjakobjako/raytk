---
layout: operator
title: basicMat
parent: Material Operators
grand_parent: Operators
permalink: /reference/operators/material/basicMat
redirect_from:
  - /reference/opType/raytk.operators.material.basicMat/
op:
  category: material
  detail: 'The material combines several elements to determine the color of a given
    surface point.


    First, the base color uses the `Basecolor` parameter and optionally the `Base
    Color Field` input.

    Next, the specular color uses the color and relative position of the light.

    Third, the "Sky" color acts as a simple pseudo light, that uses the surface normal
    but doesn''t support shadows.'
  inputs:
  - contextTypes:
    - Context
    coordTypes:
    - vec3
    label: SDF Shape
    name: sdf
    required: true
    returnTypes:
    - Sdf
  - contextTypes:
    - MaterialContext
    coordTypes:
    - vec3
    label: Base Color Field
    name: baseColorField
    returnTypes:
    - float
    - vec4
    supportedVariables:
    - lightcolor
    - lightpos
    - surfacecolor
    - surfaceuv
    - normal
  name: basicMat
  opType: raytk.operators.material.basicMat
  parameters:
  - label: Enable
    name: Enable
  - label: Base Color
    name: Basecolor
    readOnlyHandling: baked
    regularHandling: runtime
  - label: Sky Color
    name: Skycolor
    readOnlyHandling: baked
    regularHandling: runtime
    summary: Color of the "sky" pseudo-light.
  - label: Sky Amount
    name: Skyamount
    summary: Amount of "sky" light to apply.
  - label: Sky Direction
    name: Skydir
    readOnlyHandling: baked
    regularHandling: runtime
    summary: Vector of the direction where the "sky" light comes from.
  - label: Specular Amount
    name: Specularamount
    readOnlyHandling: baked
    regularHandling: runtime
    summary: Amount of specular light color to apply.
  - label: Specular Exponent
    name: Specularexp
    readOnlyHandling: baked
    regularHandling: runtime
    summary: Controls the sharpness of the specular color rolloff.
  - label: Enable Shadow
    name: Enableshadow
    readOnlyHandling: baked
    regularHandling: baked
    summary: Whether to use shadows. If this is enabled, and the `Shadow` input is
      connected, that type of shadow is used. If it is enabled but that input is not
      connected, the default shadow is used.
  - label: Use Local Position
    name: Uselocalpos
    readOnlyHandling: baked
    regularHandling: baked
    summary: Whether to use the "local" position relative to the input shape when
      looking up colors using the `Base Color Field` input. If enabled, the coordinates
      used for the color field will be "before" any downstream transformations are
      applied. When disabled, the final global position where a point ends up in the
      render is used instead.
  - label: Use Surface Color
    name: Usesurfacecolor
    readOnlyHandling: baked
    regularHandling: baked
  - label: Apply When
    menuOptions:
    - label: Always
      name: always
    - label: Only If Unassigned
      name: missing
    name: Condition
    readOnlyHandling: baked
    regularHandling: runtime
  summary: Material with a basic lighting model.
  thumb: assets/images/reference/operators/material/basicMat_thumb.png
  variables:
  - label: Light Color
    name: lightcolor
  - label: Light Position
    name: lightpos
  - label: Surface Color (r, g, b, is set)
    name: surfacecolor
  - label: Surface UV (u, v, w, is set)
    name: surfaceuv
  - label: Surface Normal
    name: normal

---


Material with a basic lighting model.

The material combines several elements to determine the color of a given surface point.

First, the base color uses the `Basecolor` parameter and optionally the `Base Color Field` input.
Next, the specular color uses the color and relative position of the light.
Third, the "Sky" color acts as a simple pseudo light, that uses the surface normal but doesn't support shadows.