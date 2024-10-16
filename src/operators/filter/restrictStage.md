Restricts which render stages an operator is used in.


This can be used for optimization, by switching off expensive ROPs for shadows.
It can also be used to have shapes that are invisible but still cast shadows.

In cases where the main operator is not being included, this will produce either the alternative operator input (if connected), or a default value otherwise.
The default value is "non-hit" for SDFs, and `0` / `vec4(0)` etc for other types.

## Parameters

* `Enable`
* `Includeprimary`: Whether the operator should be used in the main raymarching stage where the renderer finds surface hits for rays.
* `Includeshadow`: Whether the operator should be used when the renderer is checking for shadows cast on a surface.
* `Includereflect`: Whether the operator should be used when the renderer is determining colors reflected onto surfaces.
* `Includematerial`: Whether the operator should be used when the renderer is using a material do determine the color of a point on a surface.
* `Includeocclusion`: Whether the operator should be used when the renderer is computing ambient occlusion.
* `Includevolumetric`: Whether the operator should be used when the renderer is accumulating color within a light volume.
* `Includevolumetricshadow`: Whether the operator should be used when the renderer is checking for shadows within a light volume.
* `Includenormal`: Whether the operator should be used when the renderer is calculating surface normals.

## Inputs

* `definition_in`: 
* `alternate_definition_in`: 