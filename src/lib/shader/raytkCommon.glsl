// raytkCommon.glsl

float mixVals(float a, float b, float x) { return mix(a, b, x); }
vec2 mixVals(vec2 a, vec2 b, float x) { return mix(a, b, x); }
vec3 mixVals(vec3 a, vec3 b, float x) { return mix(a, b, x); }
vec4 mixVals(vec4 a, vec4 b, float x) { return mix(a, b, x); }

void initDefVal(out float val) { val = 0.; }
void initDefVal(out vec4 val) { val = vec4(0.); }

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

vec3 modZigZag(vec3 p) {
	vec3 modded = mod(p, 2.);
	return vec3(
	modded.x > 1 ? (2 - modded.x) : modded.x,
	modded.y > 1 ? (2 - modded.y) : modded.y,
	modded.z > 1 ? (2 - modded.z) : modded.z);
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

vec2 modZigZag(vec2 p, vec2 low, vec2 high) {
	p -= low;
	vec2 range = high - low;
	vec2 range2 = range * 2.;
	vec2 modded = mod(p, range2);
	return low + vec2(
	modded.x > range.x ? (range2.x - modded.x): modded.x,
	modded.y > range.y ? (range2.y - modded.y): modded.y);
}

vec3 modZigZag(vec3 p, vec3 low, vec3 high) {
	p -= low;
	vec3 range = high - low;
	vec3 range2 = range * 2.;
	vec3 modded = mod(p, range2);
	return low + vec3(
	modded.x > range.x ? (range2.x - modded.x): modded.x,
	modded.y > range.y ? (range2.y - modded.y): modded.y,
	modded.z > range.z ? (range2.z - modded.z): modded.z);
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

float wrapRange(float value, float low, float high) {
	return low + mod(value - low, high - low);
}

vec2 wrapRange(vec2 value, vec2 low, vec2 high) {
	return low + mod(value - low, high - low);
}

vec3 wrapRange(vec3 value, vec3 low, vec3 high) {
	return low + mod(value - low, high - low);
}

vec4 wrapRange(vec4 value, vec4 low, vec4 high) {
	return low + mod(value - low, high - low);
}

// There are definitely much more efficient ways to do this..

bool allInRange(float val, float low, float high) {
	return val >= low && val <= high;
}

bool allInRange(vec2 val, vec2 low, vec2 high) {
	return val.x >= low.x && val.x <= high.x &&
				 val.y >= low.y && val.y <= high.y;
}

bool allInRange(vec3 val, vec3 low, vec3 high) {
	return val.x >= low.x && val.x <= high.x &&
				 val.y >= low.y && val.y <= high.y &&
				 val.z >= low.z && val.z <= high.z;
}

bool allInRange(vec4 val, vec4 low, vec4 high) {
	return val.x >= low.x && val.x <= high.x &&
				 val.y >= low.y && val.y <= high.y &&
				 val.z >= low.z && val.z <= high.z &&
				 val.w >= low.w && val.w <= high.w;
}

int findMin(vec2 vals, out float minVal) {
	if (vals.x < vals.y) {
		minVal = vals.x;
		return 0;
	} else {
		minVal = vals.y;
		return 1;
	}
}

int findMin(vec3 vals, out float minVal) {
	int i = findMin(vals.xy, minVal);
	if (minVal < vals.z) {
		return i;
	} else {
		minVal = vals.z;
		return 2;
	}
}

int findMin(vec4 vals, out float minVal) {
	int i = findMin(vals.xyz, minVal);
	if (minVal < vals.w) {
		return i;
	} else {
		minVal = vals.w;
		return 3;
	}
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

float quantizeHard(float p, float size, float offset) {
	return (floor((p + offset) / size) * size) - offset;
}

vec4 quantizeHard(vec4 p, vec4 size, vec4 offset) {
	return (floor(p = (p + offset) / size) * size) - offset;
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
	a = mod(a1, angle) - angle/2.;

	p = vec2(cos(a), sin(a))*r;
	// For an odd number of repetitions, fix cell index of the cell in -x direction
	// (cell index would be e.g. -5 and 5 in the two halves of the cell):
	if (abs(c) >= (repetitions/2)) c = abs(c);
	return c;
}

float pModPolarInterval(inout vec2 p, float repetitions, float start, float stop) {
	float angle = 2.*PI/repetitions;
	float a = atan(p.y, p.x) + angle/2.;
	float r = length(p);
	float c = floor(a/angle);
	float a2 = mod(a, 2.*PI)/angle;
	if (a2 < start) {
		return -1.;
	}
	if (a2 > stop) {
		return repetitions + 1.;
	}

	a = mod(a,angle) - angle/2.;
	p = vec2(cos(a), sin(a))*r;
	// For an odd number of repetitions, fix cell index of the cell in -x direction
	// (cell index would be e.g. -5 and 5 in the two halves of the cell):
	if (abs(c) >= (repetitions/2)) c = abs(c);
	return c;
}

float pModPolarIntervalMirror(inout vec2 p, float repetitions, float start, float stop) {
	float angle = 2*PI/repetitions;
	float a = atan(p.y, p.x) + angle/2.;
	float r = length(p);
	float c = floor(a/angle);
	float a2 = mod(a, 2.*PI)/angle;
	if (a2 < start) {
		return -1.;
	}
	if (a2 > stop) {
		return repetitions + 1.;
	}
	float a1 = mod(a, angle * 2);
	if (a1 >= angle) {
		a1 = angle - a1;
	}
	a = mod(a1, angle) - angle/2.;

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

// c: phase/shift, w: width
float cubicPulse( float x, float c, float w )
{
	x = abs(x - c);
	if (x>w) return 0.0;
	x /= w;
	return 1.0 - x*x*(3.0-2.0*x);
}

float gain(float x, float k)
{
	float a = 0.5*pow(2.0*((x<0.5)?x:1.0-x), k);
	return (x<0.5)?a:1.0-a;
}

float parabola(float x, float k)
{
	return pow(4.0*x*(1.0-x), k);
}

float exponentialEasing(float x, float a)
{
	const float epsilon = 0.00001;
	const float min_param_a = 0.0 + epsilon;
	const float max_param_a = 1.0 - epsilon;
	a = max(min_param_a, min(max_param_a, a));

	if (a < 0.5)
	{
		// emphasis
		a = 2.0*(a);
		float y = pow(x, a);
		return y;
	} else {
		// de-emphasis
		a = 2.0*(a-0.5);
		float y = pow(x, 1.0/(1-a));
		return y;
	}
}

// https://iquilezles.org/www/articles/smoothstepintegral/smoothstepintegral.htm
float smoothstepIntegral(float b, float x) {
	if( x>=b ) return x - 0.5*b;
	float f = x/b;
	return f*f*f*(b-x*0.5);
}

vec3 opCheapBendPos(vec3 p, float k)
{
	float c = cos(k*p.x);
	float s = sin(k*p.x);
	mat2  m = mat2(c, -s, s, c);
	return vec3(m*p.xy, p.z);
}

// https://www.shadertoy.com/view/3llfRl
vec2 opKink(vec2 p, vec2 c, float k) {
	p -= c;
	//to polar coordinates
	float ang = atan(p.x, p.y);
	float len = length(p);
	//warp angle with sigmoid function
	ang -= ang/sqrt(1.+ang*ang)*(1.-k);
	//to cartesian coordiantes
	return vec2(sin(ang),cos(ang))*len + c;
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


vec4 qsqr(in vec4 a)// square a quaterion
{
	return vec4(
		a.x*a.x - a.y*a.y - a.z*a.z - a.w*a.w,
		2.0*a.x*a.y,
		2.0*a.x*a.z,
		2.0*a.x*a.w);
}

vec3 boxFold(vec3 p, float r) {
	return clamp(p.xyz, -r, r) * 2.0 - p;
}

vec3 mengerFold(vec3 p) {
	float a = min(p.x - p.y, 0.0);
	p.x -= a;
	p.y += a;
	a = min(p.x - p.z, 0.0);
	p.x -= a;
	p.z += a;
	a = min(p.y - p.z, 0.0);
	p.y -= a;
	p.z += a;
	return p;
}

// Barycentric to Cartesian
vec3 bToC(vec3 A, vec3 B, vec3 C, vec3 barycentric) {
	return barycentric.x * A + barycentric.y * B + barycentric.z * C;
}

// Normal for the perpendicular bisector plane of two points
vec3 bisector(vec3 a, vec3 b) {
	return normalize(cross(
		mix(a, b, .5),
		cross(a, b)
	));
}

float smin(float a, float b, float k){
	float f = clamp(0.5 + 0.5 * ((a - b) / k), 0., 1.);
	return (1. - f) * a + f  * b - f * (1. - f) * k;
}

float smax(float a, float b, float k) {
	return -smin(-a, -b, k);
}

float dot2( in vec2 v ) { return dot(v,v); }
float dot2( in vec3 v ) { return dot(v,v); }

// Maps values from (inMin..inMax) to (0..1) range. This is the inverse of mix().
float map01(float value, float inMin, float inMax) {
	return (value - inMin) / (inMax - inMin);
}
vec2 map01(vec2 value, vec2 inMin, vec2 inMax) {
	return (value - inMin) / (inMax - inMin);
}
vec3 map01(vec3 value, vec3 inMin, vec3 inMax) {
	return (value - inMin) / (inMax - inMin);
}

// from Logarithmic Mobius Transform by Shane
// https://www.shadertoy.com/view/4dcSWs
vec2 spiralZoom(vec2 p, vec2 offs, float n, float spiral, float zoom, vec2 phase) {
	p -= offs;
	float a = atan(p.y, p.x)/6.283;
	float d = log(length(p));
	return vec2(a*n + d*spiral, -d*zoom + a) + phase;
}
// Standard Mobius transform: f(z) = (az + b)/(cz + d). Slightly obfuscated.
vec2 mobiusTransform(vec2 p, vec2 z1, vec2 z2) {
	z1 = p - z1; p -= z2;
	return vec2(dot(z1, p), z1.y*p.x - z1.x*p.y) / dot(p, p);
}

// Based on https://gist.github.com/Dan-Piker/f7d790b3967d41bff8b0291f4cf7bd9e
// and https://github.com/DBraun/TouchDesigner_Shared/tree/master/Starters/moebius_transformations
vec3 sphericalMobiusTransform(vec3 p, float radius, float rotAmt, vec3 rotation) {
	mat3 rMat3 = TDRotateOnAxis(rotation.x, vec3(1, 0, 0)) *
		TDRotateOnAxis(rotation.y, vec3(0, 1, 0)) *
		TDRotateOnAxis(rotation.z, vec3(0, 0, 1));
	mat4 rMat4 = mat4(
		rMat3[0].xyz, 0,
		rMat3[1].xyz, 0,
		rMat3[2].xyz, 0,
		0, 0, 0, 1);

	p = (rMat4*vec4(p, 1.)).xyz / radius;

	float xa = p.x;
	float ya = p.y;
	float za = p.z;

	float rp = 0.; //set to the same as rq for isoclinic rotations
	float rq = 1.0;

	// reverse stereographic projection to hypersphere
	float xb = 2 * xa / (1 + xa * xa + ya * ya + za * za);
	float yb = 2 * ya / (1 + xa * xa + ya * ya + za * za);
	float zb = 2 * za / (1 + xa * xa + ya * ya + za * za);
	float wb = (-1 + xa * xa + ya * ya + za * za) / (1 + xa * xa + ya * ya + za * za);

	// rotate hypersphere by amount t
	float t = rotAmt;
	float xc = +xb * cos(rp * t) + yb * sin((rp) * t);
	float yc = -xb * sin(rp * t) + yb * cos((rp) * t);
	float zc = +zb * cos(rq * t) - wb * sin((rq) * t);
	float wc = +zb * sin(rq * t) + wb * cos((rq) * t);

	// project stereographically back to flat 3D
	float xd = xc / (1 - wc);
	float yd = yc / (1 - wc);
	float zd = zc / (1 - wc);

	return (
		inverse(rMat4) *
		vec4(vec3(xd, yd, zd) * radius, 1.)
	).xyz;
}

Ray createStandardCameraRay(vec2 p, vec2 size, int viewAngleMethod, float fov, mat4 camMat) {
	vec2 uv = p / size;
	float z = mix(size.x, size.y, float(viewAngleMethod)) / tan(radians(fov) * 0.5) * 0.5;
	Ray ray;
	ray.pos = camMat[3].xyz;
	ray.dir = mat3(camMat) * normalize(vec3((uv - 0.5) * size, -z));
	return ray;
}

// https://iquilezles.org/www/articles/palettes/palettes.htm
// https://github.com/Erkaman/glsl-cos-palette
vec3 cosPalette(  float t,  vec3 a,  vec3 b,  vec3 c, vec3 d ){
	return a + b*cos( 6.28318*(c*t+d) );
}

// https://github.com/CesiumGS/cesium/blob/master/Source/Shaders/Builtin/Functions/
vec3 czm_saturation(vec3 rgb, float adjustment)
{
	// Algorithm from Chapter 16 of OpenGL Shading Language
	const vec3 W = vec3(0.2125, 0.7154, 0.0721);
	vec3 intensity = vec3(dot(rgb, W));
	return mix(intensity, rgb, adjustment);
}
// adjustment is in radians
vec3 czm_hue(vec3 rgb, float adjustment)
{
	const mat3 toYIQ = mat3(0.299,     0.587,     0.114,
	0.595716, -0.274453, -0.321263,
	0.211456, -0.522591,  0.311135);
	const mat3 toRGB = mat3(1.0,  0.9563,  0.6210,
	1.0, -0.2721, -0.6474,
	1.0, -1.107,   1.7046);

	vec3 yiq = toYIQ * rgb;
	float hue = atan(yiq.z, yiq.y) + adjustment;
	float chroma = sqrt(yiq.z * yiq.z + yiq.y * yiq.y);

	vec3 color = vec3(yiq.x, chroma * cos(hue), chroma * sin(hue));
	return toRGB * color;
}

float adaptAsFloat(float p) { return p; }
float adaptAsFloat(vec2 p) { return p.x; }
float adaptAsFloat(vec3 p) { return p.x; }
float adaptAsFloat(vec4 p) { return p.x; }
float adaptAsFloat(Sdf res) { return res.x; }

vec2 adaptAsVec2(float p) { return vec2(p, 0.); }
vec2 adaptAsVec2(vec2 p) { return p; }
vec2 adaptAsVec2(vec3 p) { return p.xy; }
vec2 adaptAsVec2(vec4 p) { return p.xy; }

vec3 adaptAsVec3(float p) { return vec3(p, 0., 0.); }
vec3 adaptAsVec3(vec2 p) { return vec3(p, 0.); }
vec3 adaptAsVec3(vec3 p) { return p; }
vec3 adaptAsVec3(vec4 p) { return p.xyz; }

vec4 adaptAsVec4(float p) { return vec4(p, 0., 0., 0.); }
vec4 adaptAsVec4(vec2 p) { return vec4(p, 0., 0.); }
vec4 adaptAsVec4(vec3 p) { return vec4(p, 0.); }
vec4 adaptAsVec4(vec4 p) { return p; }

vec2 fillToVec2(float p) { return vec2(p); }
vec2 fillToVec2(vec4 p) { return p.xy; }

vec3 fillToVec3(float p) { return vec3(p); }
vec3 fillToVec3(vec4 p) { return p.xyz; }

float extractOrUseAsX(float p) { return p; }
float extractOrUseAsX(vec2 p) { return p.x; }
float extractOrUseAsX(vec3 p) { return p.x; }
float extractOrUseAsX(vec4 p) { return p.x; }

float extractOrUseAsY(float p) { return p; }
float extractOrUseAsY(vec4 p) { return p.y; }

float extractOrUseAsZ(float p) { return p; }
float extractOrUseAsZ(vec4 p) { return p.z; }

float extractOrUseAsW(float p) { return p; }
float extractOrUseAsW(vec4 p) { return p.w; }

void setFromFloat(inout float x, float val) { x = val; }
void setFromFloat(inout Sdf x, float val) { x.x = val; }

void swap(inout Sdf a, inout Sdf b) {
	Sdf tmp = a;
	a = b;
	b = tmp;
}
