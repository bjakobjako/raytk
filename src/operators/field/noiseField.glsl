ReturnT thismap(CoordT p, ContextT ctx) {
	#ifdef THIS_HAS_INPUT_coordField
	p = THIS_asCoordT(inputOp_coordField(p, ctx));
	#endif
	THIS_NOISE_COORD_TYPE q;
	#if defined(THIS_COORD_TYPE_vec2)
		q = THIS_asNoiseCoordT(p);
	#elif defined(THIS_COORD_TYPE_vec3)
		#ifdef THIS_NOISE_COORD_vec2
		q = getAxisPlane(p, int(THIS_Axis));
		#else
		q = THIS_asNoiseCoordT(p);
		#endif
	#endif
	q -= THIS_asNoiseCoordT(THIS_Translate);
	q /= THIS_asNoiseCoordT(THIS_Scale);

	ReturnT res;
	BODY();
	return (res * THIS_Amplitude) + THIS_Offset;
}