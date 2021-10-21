ReturnT thismap(CoordT p, ContextT ctx) {
	Light light;
	light.pos = THIS_Position;
	light.pos.THIS_AXIS = p.THIS_AXIS;
	light.color = THIS_Color * THIS_Intensity;
	#ifdef THIS_HAS_INPUT_colorField
	light.color *= fillToVec3(inputOp_colorField(p, ctx));
	#endif
	#ifdef THIS_Enableattenuation
	{
		float d = length((p - light.pos).THIS_PLANE);
		float start = THIS_Attenuationstart;
		float end = THIS_Attenuationend;
		float atten = smoothstep(end, start, d);
		#ifdef THIS_HAS_INPUT_attenuationField
		light.color *= fillToVec3(inputOp_attenuationField(atten, ctx));
		#else
		light.color *= atten;
		#endif
	}
		#endif
	return light;
}