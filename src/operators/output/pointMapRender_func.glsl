Light getLight(vec3 p, LightContext ctx) {
	Light res;
#if defined(THIS_HAS_INPUT_light) && defined(THIS_HAS_TAG_uselight)
	res = inputOp_light(p, ctx);
#else
	res = createLight(vec3(0.), vec3(5.8, 4., 3.5));
#endif
	return res;
}

Ray getViewRay(vec2 shift) {
	vec2 resolution = uTDOutputInfo.res.zw;
	vec2 p = vUV.st*resolution + shift;
	CameraContext ctx;
	ctx.resolution = resolution;
	Ray res;
	#if defined(THIS_HAS_INPUT_camera) && defined(THIS_HAS_TAG_useray)
	res = inputOp_camera(p, ctx);
	#else
	mat4 camMat = mat4(
		1., 0., 0., 0.,
		0., 1., 0., 0.,
		0., 0., 1., 0.,
		0., 0., 5., 0.
	);
	res = createStandardCameraRay(
		p,
		ctx.resolution,
		0,
		45,
		camMat
	);
	#endif
	return res;
}

ReturnT thismap(CoordT p, ContextT ctx) {
	#ifdef THIS_HAS_INPUT_1
	return inputOp1(p, ctx);
	#else
	return createNonHitSdf();
	#endif
}
