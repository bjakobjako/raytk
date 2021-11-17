// from Logarithmic Mobius Transform by Shane
// https://www.shadertoy.com/view/4dcSWs
ReturnT thismap(CoordT p, ContextT ctx) {
	#if defined(THIS_COORD_TYPE_vec2)
	vec2 q = p;
	#elif defined(THIS_COORD_TYPE_vec3)
	vec2 q = p.THIS_PLANE;
	#else
	#error invalidCoordType
	#endif

	q -= THIS_Center;
	float a = atan(q.y, q.x)/TAU;
	float r = log(length(q));
	float n = THIS_Branches;
	float spiral = THIS_Twist1;
	float zoom = THIS_Twist2;

	q = vec2(a*n + r*spiral, -r*zoom + a) + THIS_Phase;

	#if defined(THIS_COORD_TYPE_vec2)
	return inputOp1(q, ctx);
	#elif defined(THIS_COORD_TYPE_vec3)
	p.THIS_PLANE = q;
	return inputOp1(p, ctx);
	#else
	#error invalidCoordType
	#endif
}
