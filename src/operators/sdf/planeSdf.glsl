ReturnT thismap(CoordT p, ContextT ctx) {
	ReturnT res = createSdf(p.THIS_AXIS - THIS_Offset);
	#ifdef RAYTK_USE_UV
	assignUV(res, vec3(p.THIS_PLANE, 0.));
	#endif
	return res;
}