Renderer that takes in a TOP of coordinates and evaluates the scene at each point.

The primary use for this is with TOP-based instancing for a Geometry COMP:

* Create a TOP with a coordinate value in each pixel. For example, this could be point cloud data, or converted points from a SOP/CHOP.
* Create your RayTK scene network, with an SDF or value/vector field.
* (Optionally) add a `sampledPointMat` to the scene to control how colors are applied to shapes.
* Create a `pointMapRender`, and connect the scene to the first input and the coordinate TOP to the TOP input.
* The TOP that comes out of the "Color" output will be a TOP with the same dimensions as the coordinate TOP, with a color value for each pixel, based on the scene.
* On a Geometry COMP, with instancing on, use the coordinate TOP for the instance positions, and use the colors TOP from the `pointMapRender` for the instance colors.

Other uses include:
* LED pixel mapping, where you use the physical location of each LED for the coordinates, and apply the resulting colors to each LED.
* GPU particles, where the simulation GLSL TOP produces coordinates from one buffer, which are run through the `pointMapRender`, and then feed the resulting values back into the simulation to control particle forces for each particle/pixel.

The "SDF or Value" output, when using an SDF scene, will output values where the RGB channels contain the distance to the surface. The alpha channel will be one for points that existed in the input map and zero for ones that did not. In other words the alpha channel will be the same as the alpha channel in the input point map.

## Parameters

* `Format`
  * `useinput`
  * `rgba8fixed`
  * `srgba8fixed`
  * `rgba16float`
  * `rgba32float`
  * `_separator_`
  * `rgb10a2fixed`
  * `rgba16fixed`
  * `rgba11float`
  * `mono8fixed`
  * `mono16fixed`
  * `mono16float`
  * `mono32float`
  * `rg8fixed`
  * `rg16fixed`
  * `rg16float`
  * `rg32float`
  * `a8fixed`
  * `a16fixed`
  * `a16float`
  * `a32float`
  * `monoalpha8fixed`
  * `monoalpha16fixed`
  * `monoalpha16float`
  * `monoalpha32float`
* `Enablenormaloutput`: Enable producing normal vectors. For each point, this will produce a vector pointing in the direction that the nearest surface point is facing. These values can be accessed using a `renderSelect` operator.
* `Enableobjectidoutput`: Enable object ID output, which produces a TOP with values assigned with the `injectObjectId` operator for whichever shape each point is inside.
* `Timerefop`
* `Shaderbuilderconfig`
* `Coordtype`
  * `auto`
  * `vec2`
  * `vec3`
* `Outputtype`
  * `texture2d`
  * `texture2darray`
  * `texture3d`
* `Enabledensityoutput`
* `Enabledebugoutput`
* `Enablecustomoutput1`
* `Enablecustomoutput2`
* `Enablenormalsmoothing`: Whether to smooth out surface normals by sampling at larger distances.
* `Normalsmoothing`: How far apart to sample to calculate surface normals.
* `Materialmode`
  * `inside`
  * `surface`
  * `everywhere`
* `Enableblending`
* `Blending`
* `Thickness`
* `Customizeshaderconfig`

## Inputs

* `definition_in`: 
* `camera`: 
* `light`: 

## Variables

* `datapos`: 
* `datauv`: 
* `datares`: 