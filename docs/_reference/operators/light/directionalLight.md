---
layout: operator
title: directionalLight
parent: Light Operators
grand_parent: Operators
permalink: /reference/operators/light/directionalLight
redirect_from:
  - /reference/opType/raytk.operators.light.directionalLight/
op:
  category: light
  detail: The light always comes from the specified direction, rather than from a
    point.
  inputs:
  - contextTypes:
    - LightContext
    coordTypes:
    - vec3
    label: Color Field
    name: colorField
    returnTypes:
    - float
    - vec4
    supportedVariables:
    - lightdir
  name: directionalLight
  opType: raytk.operators.light.directionalLight
  parameters:
  - label: Direction
    name: Direction
    readOnlyHandling: baked
    regularHandling: runtime
    summary: Vector pointing which direction the light shines. This vector is automatically
      normalized.
  - label: Intensity
    name: Intensity
    readOnlyHandling: baked
    regularHandling: runtime
    summary: Brightness that is applied to the `Color`.
  - label: Color
    name: Color
    readOnlyHandling: baked
    regularHandling: runtime
  - label: Rotate
    name: Rotate
    readOnlyHandling: baked
    regularHandling: runtime
    summary: Rotates the direction of the light on all 3 axes.
  - label: Enable Shadow
    name: Enableshadow
    readOnlyHandling: semibaked
    regularHandling: runtime
    summary: Whether this light should cast shadows.
  summary: A directional light.
  variables:
  - label: RTK_raytk_operators_light_directionalLight_lightdir
    name: RTK_raytk_operators_light_directionalLight_lightdir
  - label: lightdir
    name: lightdir

---


A directional light.

The light always comes from the specified direction, rather than from a point.