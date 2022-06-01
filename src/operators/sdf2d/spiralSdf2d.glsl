// Based on https://www.shadertoy.com/view/3ss3W7#

ReturnT thismap(CoordT p, ContextT ctx) {
	float a = 1.0;  // not sure what this is for
	#ifdef THIS_HAS_INPUT_spreadField
	float b = inputOp_spreadField(p, ctx);
	#else
	float b = THIS_Spread;
	#endif

	//https://swiftcoder.wordpress.com/2010/06/21/logarithmic-spiral-distance-field/
	//# calculate the target radius and theta
	float r = length(p);
	#ifdef THIS_HAS_INPUT_rotateField
	float rot = radians(inputOp_rotateField(p, ctx));
	#else
	float rot = THIS_Rotate;
	#endif
	float t = atan(p.y, p.x) + rot;

	//# early exit if the point requested is the origin itself
	//# to avoid taking the logarithm of zero in the next step
	if (r == 0.)
	{
		return createSdf(0.);
	}

	// calculate the floating point approximation for n
	// calculate n
	float n = floor((log(r / a) / b - t) / (2.0 * PI));

	// find the two possible radii for the closest point
	float lower_r = a * exp(b * (t + 2.0 * PI * n));
	float upper_r = lower_r * exp(2.0 * PI * b);

	#pragma r:if THIS_Useradiuslimit
	#pragma r:if THIS_HAS_INPUT_radiusLimitField
	float r2 = r - inputOp_radiusLimitField(p, ctx);
	#pragma r:else
	float r2 = r - THIS_Radiuslimit;
	#pragma r:endif
	#pragma r:else
	float r2 = -r;
	#pragma r:endif

	#ifdef THIS_HAS_INPUT_thicknessField
	float th = inputOp_thicknessField(p, ctx);
	#else
	float th = THIS_Thickness;
	#endif

	// return the minimum distance to the target point
	float d =
		max(
			r2,
			(min(abs(upper_r - r), abs(r - lower_r)) - th)
	);

	return createSdf(d);
}