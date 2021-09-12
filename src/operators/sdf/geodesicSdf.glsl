// https://www.shadertoy.com/view/4tG3zW

ReturnT thismap(CoordT p, ContextT ctx) {
	float s = THIS_Divisions;
	#if defined(THIS_Shape_dodecahedron)
	vec3 n = pDodecahedron(p, int(s));
	#elif defined(THIS_Shape_icosahedron)
	vec3 n = pIcosahedron(p, int(s));
	#else
	#error invalidShape
	#endif

	float d = RAYTK_MAX_DIST;
	#if defined(THIS_Enablespikes)
	float spikeSize = .08 + (2. - s) * THIS_Spikeradius;
	d = min(d, fCone(p, spikeSize, THIS_Spikelength, n, THIS_Spikeoffset));
	#endif
	#ifdef THIS_Enablefaces
	d = min(d, fPlane(p, n, -THIS_Faceoffset));
	#endif
	#ifdef THIS_HAS_INPUT_1
	p -= n * (THIS_Spikeoffset + THIS_Spikelength);
	p = reflect(p, normalize(mix(vec3(0,1,0), -n, .5)));
	d = min(d, inputOp1(p, ctx).x);
	ReturnT res = inputOp1(p, ctx);
	res.x = min(res.x, d);
	return res;
	#else
	return createSdf(d);
	#endif
}