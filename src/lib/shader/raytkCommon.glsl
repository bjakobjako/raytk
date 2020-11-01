// raytkCommon.glsl

struct Ray {
	vec3 pos;
	vec3 dir;
};

struct Sdf {
	float x; // distance
	float material; // material ID
	float material2; // in case of interpolating, the second material
	float interpolant; // in case of interpolating, the interpolation value
	float ior; // index of refraction in case of refraction
	bool reflect; // do reflection for this?
	bool refract; // do refraction for this?

	#ifdef RAYTK_ORBIT_IN_SDF
	vec4 orbit;  // orbit trap value for fractals
	#endif

	#ifdef RAYTK_STEPS_IN_SDF
	int steps;
	#endif

	#ifdef RAYTK_NEAR_HITS_IN_SDF
	int nearHitCount;
	float nearHitAmount;
	#endif

	#ifdef RAYTK_ITERATION_IN_SDF
	vec4 iteration;
	#endif

	#ifdef RAYTK_OBJECT_ID_IN_SDF
	// x: Primary object id number
	// y: Secondary object id number (or zero)
	// z: Interpolant between primary and secondary
	// w: unused
	vec4 objectId;
	#endif
};

Sdf createSdf(float dist) {
	Sdf res;
	res.x = dist;
	res.material = 2;
	res.reflect = false;
	res.refract = false;
	res.material2 = 0.;
	res.interpolant = 0.;
	#ifdef RAYTK_ORBIT_IN_SDF
	res.orbit = vec4(0);
	#endif
	#ifdef RAYTK_STEPS_IN_SDF
	res.steps = 0;
	#endif
	#ifdef RAYTK_NEAR_HITS_IN_SDF
	res.nearHitCount = 0;
	res.nearHitAmount = 0.;
	#endif
	#ifdef RAYTK_ITERATION_IN_SDF
	res.iteration = vec4(0);
	#endif
	#ifdef RAYTK_OBJECT_ID_IN_SDF
	res.objectId = vec4(0);
	#endif
	return res;
}

struct Context {
	vec4 iteration;
};

Context createDefaultContext() {
	Context ctx;
	ctx.iteration = vec4(0);
	return ctx;
}

struct Light {
	vec3 pos;
	vec3 color;  // Includes brightness. May be determined specific to a particular point in space (such as attentuation).
};

struct LightContext {
	Sdf result;
	vec3 normal;
};

struct MaterialContext {
	Sdf result;
	Context context;
	Ray ray;
	Light light;
	vec3 normal;
};

struct CameraContext {
	vec2 resolution;
};

mat3 rotateMatrix(vec3 r) {
	return TDRotateX(r.x) * TDRotateY(r.y) * TDRotateZ(r.z);
}


void pRotateOnXYZ(inout vec3 p, vec3 rotation) {
	vec2 temp;
	temp = p.xy;
	pR(temp, rotation.z);
	p.xy = temp;
	temp = p.xz;
	pR(temp, rotation.y);
	p.xz = temp;
	temp = p.yz;
	pR(temp, rotation.x);
	p.yz = temp;
}

int quadrantIndex(ivec2 cell) {
	/*
	[0] -1, 1    [1] 1, 1
	[2] -1, -1   [3] 1, -1
	*/
	return (((cell.y + 1) / 2) * 2) + ((cell.x + 1) / 2);
}

// https://github.com/msfeldstein/glsl-map/blob/master/index.glsl

float mapRange(float value, float inMin, float inMax, float outMin, float outMax) {
	return outMin + (outMax - outMin) * (value - inMin) / (inMax - inMin);
}

vec2 mapRange(vec2 value, vec2 inMin, vec2 inMax, vec2 outMin, vec2 outMax) {
	return outMin + (outMax - outMin) * (value - inMin) / (inMax - inMin);
}

vec3 mapRange(vec3 value, vec3 inMin, vec3 inMax, vec3 outMin, vec3 outMax) {
	return outMin + (outMax - outMin) * (value - inMin) / (inMax - inMin);
}

vec4 mapRange(vec4 value, vec4 inMin, vec4 inMax, vec4 outMin, vec4 outMax) {
	return outMin + (outMax - outMin) * (value - inMin) / (inMax - inMin);
}

float modZigZag(float p) {
	float modded = mod(p, 2.);
	if (modded > 1) {
		return 2 - modded;
	}
	return modded;
}

vec2 modZigZag(vec2 p) {
	vec2 modded = mod(p, 2.);
	return vec2(
		modded.x > 1 ? (2 - modded.x) : modded.x,
		modded.y > 1 ? (2 - modded.y) : modded.y);
}

vec4 modZigZag(vec4 p) {
	vec4 modded = mod(p, 2.);
	return vec4(
		modded.x > 1 ? (2 - modded.x) : modded.x,
		modded.y > 1 ? (2 - modded.y) : modded.y,
		modded.z > 1 ? (2 - modded.z) : modded.z,
		modded.w > 1 ? (2 - modded.w) : modded.w);
}

float modZigZag(float p, float low, float high) {
	p -= low;
	float range = high - low;
	float modded = mod(p, range * 2.);
	if (modded > range) {
		return low + (range * 2. - modded);
	}
	return low + modded;
}

vec4 modZigZag(vec4 p, vec4 low, vec4 high) {
	p -= low;
	vec4 range = high - low;
	vec4 range2 = range * 2.;
	vec4 modded = mod(p, range2);
	return low + vec4(
		modded.x > range.x ? (range2.x - modded.x): modded.x,
		modded.y > range.y ? (range2.y - modded.y): modded.y,
		modded.z > range.z ? (range2.z - modded.z): modded.z,
		modded.w > range.w ? (range2.w - modded.w): modded.w);
}

/**
 * Return a transform matrix that will transform a ray from view space
 * to world coordinates, given the eye point, the camera target, and an up vector.
 *
 * This assumes that the center of the camera is aligned with the negative z axis in
 * view space when calculating the ray marching direction. See rayDirection.
 */
mat4 lookAtViewMatrix(vec3 eye, vec3 center, vec3 up) {
	// Based on gluLookAt man page
	vec3 f = normalize(center - eye);
	vec3 s = normalize(cross(f, up));
	vec3 u = cross(s, f);
	return mat4(
	vec4(s, 0.0),
	vec4(u, 0.0),
	vec4(-f, 0.0),
	vec4(0.0, 0.0, 0.0, 1)
	);
}

float quantizeGain(float x, float k)
{
	float a = 0.5*pow(2.0*((x<0.5)?x:1.0-x), k);
	return (x<0.5)?a:1.0-a;
}
vec2 quantizeGain(vec2 x, vec2 k)
{
	return vec2(quantizeGain(x.x, k.x), quantizeGain(x.y, k.y));
}
vec3 quantizeGain(vec3 x, vec3 k)
{
	return vec3(quantizeGain(x.x, k.x), quantizeGain(x.y, k.y), quantizeGain(x.z, k.z));
}
vec4 quantizeGain(vec4 x, vec4 k)
{
	return vec4(quantizeGain(x.x, k.x), quantizeGain(x.y, k.y), quantizeGain(x.z, k.z), quantizeGain(x.w, k.w));
}

float quantize(float p, float size, float offset, float smoothing) {
	p = (p + offset) / size;
	return ((floor(p) + quantizeGain(fract(p), smoothing)) * size) - offset;
}

vec2 quantize(vec2 p, vec2 size, vec2 offset, vec2 smoothing) {
	p = (p + offset) / size;
	return ((floor(p) + quantizeGain(fract(p), smoothing)) * size) - offset;
}

vec3 quantize(vec3 p, vec3 size, vec3 offset, vec3 smoothing) {
	p = (p + offset) / size;
	return ((floor(p) + quantizeGain(fract(p), smoothing)) * size) - offset;
}

vec4 quantize(vec4 p, vec4 size, vec4 offset, vec4 smoothing) {
	p = (p + offset) / size;
	return ((floor(p) + quantizeGain(fract(p), smoothing)) * size) - offset;
}

float onion(float d, float thickness) {
	return abs(d)-thickness;
}
vec4 onion(vec4 d, float thickness) {
	return abs(d)-thickness;
}

float pModPolarMirror(inout vec2 p, float repetitions) {
	float angle = 2*PI/repetitions;
	float a = atan(p.y, p.x) + angle/2.;
	float r = length(p);
	float c = floor(a/angle);
//	a = mod(a,angle) - angle/2.;
	float a1 = mod(a, angle * 2);
	if (a1 >= angle) {
		a1 = angle - a1;
	}
	a1 = mod(a1, angle);
	a = a1 - angle/2.;

	p = vec2(cos(a), sin(a))*r;
	// For an odd number of repetitions, fix cell index of the cell in -x direction
	// (cell index would be e.g. -5 and 5 in the two halves of the cell):
	if (abs(c) >= (repetitions/2)) c = abs(c);
	return c;
}

// https://www.shadertoy.com/view/XdXcRB
float ndot(vec2 a, vec2 b ) { return a.x*b.x - a.y*b.y; }

// https://iquilezles.org/www/articles/functions/functions.htm
float remapAlmostIdentity( float x, float m, float n )
{
	if( x>m ) return x;
	float a = 2.0*n - m;
	float b = 2.0*m - 3.0*n;
	float t = x/m;
	return (a*t + b)*t*t + n;
}

// f: attack width
float expImpulse(float x, float k)
{
	float h = k*x;
	return h*exp(1.0-h);
}

// f: attack width
// k: release
float expSustainedImpulse(float x, float f, float k)
{
	float s = max(x-f, 0.0);
	return min(x*x/(f*f), 1+(2.0/f)*s*exp(-k*s));
}

// k: falloff
float quaImpulse(float x, float k)
{
	return 2.0*sqrt(k)*x/(1.0+k*x*x);
}

// n: polynomial degree
// k: falloff
float polyImpulse(float x, float n, float k)
{
	return (n/(n-1.0))*pow((n-1.0)*k, 1.0/n) * x/(1.0+k*pow(x, n));
}

// k: number of bounces
float sinc(float x, float k)
{
	float a = PI*(k*x-1.0);
	return sin(a)/a;
}

vec3 opCheapBendPos(vec3 p, float k)
{
	float c = cos(k*p.x);
	float s = sin(k*p.x);
	mat2  m = mat2(c, -s, s, c);
	return vec3(m*p.xy, p.z);
}

vec3 opTwistPos(vec3 p, float k)
{
	float c = cos(k*p.y);
	float s = sin(k*p.y);
	mat2  m = mat2(c,-s,s,c);
	return vec3(m*p.xz,p.y);
}

// Returns xyz: new pos, w: value to add to surface distance (which may not work correctly)
vec4 opElongate(in vec3 p, in vec3 h)
{
	//return vec4( p-clamp(p,-h,h), 0.0 ); // faster, but produces zero in the interior elongated box
	vec3 q = abs(p)-h;
	return vec4(max(q,0.0), min(max(q.x,max(q.y,q.z)),0.0));
}

#define wave_sin(x)  sin(x * TAU)
#define wave_cos(x)  cos(x * TAU)
#define wave_tri(x)  (abs(4.*fract(x)-2.)-1.)
#define wave_square(x) (2.*step(fract(x), 0.5)-1.)
#define wave_ramp(x)  fract(x)
