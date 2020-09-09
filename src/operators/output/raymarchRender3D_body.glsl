uniform vec3 camPos;
uniform vec3 camRot;
uniform vec3 lightPos1;

#define MAX_STEPS 100
#define MAX_DIST 100.0
#define SURF_DIST 0.01

Sdf map(vec3 q)
{
	Sdf res = thismap(q, createDefaultContext());
//	res.x *= 0.5;
	return res;
}

Sdf castRay(vec3 rayOrigin, vec3 rayDir, float maxDist) {
	float dist = 0;
	for (int i = 0; i < MAX_STEPS; i++) {
		vec3 p = rayOrigin + rayDir * dist;
		Sdf res = map(p);
		dist += res.x;
		if (dist < SURF_DIST) {
			return res;
		}
		if (dist > maxDist) {
			break;
		}
	}
	return createSdf(dist);
}

vec3 calcNormal(in vec3 pos)
{
	vec2 e = vec2(1.0, -1.0)*0.5773*0.005;
	return normalize(
		e.xyy*map(pos + e.xyy).x +
		e.yyx*map(pos + e.yyx).x +
		e.yxy*map(pos + e.yxy).x +
		e.xxx*map(pos + e.xxx).x);
}

float getLight(vec3 p) {
	vec3 lightPos = lightPos1;
	vec3 lightVec = normalize(lightPos - p);
	vec3 n = calcNormal(p);

	float diffuse = clamp(dot(n, lightVec), 0., 1.);

	float shadowDist = castRay(p+n * SURF_DIST*2., lightVec, MAX_DIST).x;
	if (shadowDist < length(lightPos - p)) {
		diffuse *= .1;
	}

	return diffuse;
}

layout (location = 0) out vec4 colorOut;
layout (location = 1) out vec4 sdfOut;
layout (location = 2) out vec4 depthOut;

void main()
{
	vec2 resolution = uTDOutputInfo.res.zw;
	vec2 fragCoord = vUV.st*resolution;
	vec2 rayTarget = (-resolution+2.0*fragCoord.xy)/resolution.y;

//	vec2 uv = (fragCoord-.5*resolution.xy) / resolution.y;

//	vec2 q = vUV.st;
//	float renderDepth = texture(sTD2DInputs[0], vUV.st).r;

	//-----------------------------------------------------
	// camera
	//-----------------------------------------------------

	vec3 rayOrigin = camPos;
	vec3 rayDir = normalize(vec3(rayTarget, 1));
//vec3 rayDir = normalize(vec3(uv.x, uv.y, 1));
	//-----------------------------------------------------
	// render
	//-----------------------------------------------------

	vec3 col = vec3(0);
	// raymarch
	Sdf res = castRay(rayOrigin, rayDir, MAX_DIST);
	vec3 p = rayOrigin + rayDir * res.x;

	sdfOut = TDOutputSwizzle(vec4(res.x, res.x, res.x, 1));
//	depthOut = TDOutputSwizzle(vec4(vec3(min(res.x, renderDepth)), 1));
	//depthOut = TDOutputSwizzle(vec4(vec3(res.x)))

	float diffuse = getLight(p);
	col = vec3(diffuse);

	colorOut = TDOutputSwizzle(vec4(col, 1));
}
