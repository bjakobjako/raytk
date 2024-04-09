ReturnT thismap(CoordT p, ContextT ctx) {
	ReturnT res;
	CoordT p0 = p;
	p -= THIS_Translate;
	switch (int(THIS_Axis)) {
		case 0: p = p.yxz; break;
		case 1: p = p.zyx; break;
		case 2: p = p.xzy; break;
	}
	if (IS_TRUE(THIS_Reverse)) {
		p.x *= -1;
	}
	#ifdef THIS_EXPOSE_axisoffset
	THIS_axisoffset = p.y;
	#endif
	#ifdef THIS_EXPOSE_angle
	THIS_angle = degrees(atan(p.z, p.x)) + 180;
	#endif
	#ifdef THIS_EXPOSE_normangle
	THIS_normangle = (atan(p.z, p.x) / TAU) + .5;
	#endif
	float thickness = THIS_Thickness;
	#ifdef THIS_HAS_INPUT_thicknessField
		thickness *= inputOp_thicknessField(p0, ctx);
	#endif
	float radius = THIS_Radius;
	#ifdef THIS_HAS_INPUT_radiusField
		radius *= inputOp_radiusField(p0, ctx);
	#endif
	#ifdef THIS_HAS_INPUT_spreadField
	float m = inputOp_spreadField(p0, ctx);
	#else
	float m = THIS_Spread;
	#endif
	float dualSpread = THIS_Dualspread * radius;
	float halfm = m*.5,
	b = mod(p.y, PI*m) - PI*halfm,
	a = abs(atan(p.x, p.z) * halfm - b);
	if (a > PI*halfm) a = PI*m - a;
	//optimisation from Shane
	p.xy = vec2(length(p.xz) - radius, a);
	p.x = abs(p.x) - dualSpread;
	vec2 q = p.xy;
	#ifdef THIS_HAS_INPUT_crossSection
	res = adaptAsSdf(inputOp_crossSection(q, ctx));
	#else
	res = createSdf(length(q) - thickness);
	#endif
	return res;
}