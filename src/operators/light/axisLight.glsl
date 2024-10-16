ReturnT thismap(CoordT p, ContextT ctx) {
	#ifdef THIS_HAS_INPUT_positionField
	vec3 pos = adaptAsVec3(inputOp_positionField(p, ctx));
	#else
	vec3 pos = THIS_Position;
	#endif
	pos += ctx.posOffset;
	Light light = createLight(pos, THIS_Color * THIS_Intensity);
	switch (int(THIS_Axis)) {
		case 0: light.pos.x = p.x; break;
		case 1: light.pos.y = p.y; break;
		case 2: light.pos.z = p.z; break;
	}
	pRotateOnXYZ(light.pos, THIS_Rotate + ctx.rotation);
	#ifdef THIS_EXPOSE_lightdir
	THIS_lightdir = normalize(light.pos - p);
	#endif
	light.supportShadow = IS_TRUE(THIS_Enableshadow);
	#ifdef THIS_HAS_INPUT_colorField
	light.color *= fillToVec3(inputOp_colorField(p, ctx));
	#endif
	if (IS_TRUE(THIS_Enableattenuation)) {
		float d;
		switch (int(THIS_Axis)) {
			case 0: d = length((p - light.pos).yz); break;
			case 1: d = length((p - light.pos).zx); break;
			case 2: d = length((p - light.pos).xy); break;
		}
		float start = THIS_Attenuationstart;
		float end = THIS_Attenuationend;
		float atten = smoothstep(end, start, d);
		#ifdef THIS_HAS_INPUT_attenuationField
		light.color *= fillToVec3(inputOp_attenuationField(atten, ctx));
		#else
		light.color *= atten;
		#endif
	}
	return light;
}