---
layout: operator
title: hologramContrib
parent: Material Operators
grand_parent: Operators
permalink: /reference/operators/material/hologramContrib
redirect_from:
  - /reference/opType/raytk.operators.material.hologramContrib/
op:
  category: material
  inputs:
  - contextTypes:
    - MaterialContext
    coordTypes:
    - vec3
    label: Color Field
    name: colorField
    returnTypes:
    - float
    - vec4
    supportedVariables:
    - step
    - normstep
  name: hologramContrib
  opType: raytk.operators.material.hologramContrib
  parameters:
  - label: Enable
    name: Enable
  - label: Iterations
    name: Iterations
    readOnlyHandling: baked
    regularHandling: runtime
  - label: Step Distance
    name: Step
    readOnlyHandling: baked
    regularHandling: runtime
  - label: Period
    name: Period
    readOnlyHandling: baked
    regularHandling: runtime
  - label: Phase
    name: Phase
    readOnlyHandling: baked
    regularHandling: runtime
  status: beta
  variables:
  - label: Step Index
    name: step
  - label: Normalized Step (0..1)
    name: normstep

---
