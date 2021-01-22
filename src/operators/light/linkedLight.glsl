Light thismap(vec3 p, LightContext ctx) {
	mat4 lightMat = mat4(
		THIS_m00, THIS_m10, THIS_m20, THIS_m30,
		THIS_m01, THIS_m11, THIS_m21, THIS_m31,
		THIS_m02, THIS_m12, THIS_m22, THIS_m32,
		THIS_m03, THIS_m13, THIS_m23, THIS_m33
	);
	Light light;
	light.color = vec3(THIS_cr, THIS_cg, THIS_cb);
	#if defined(THIS_lighttype_point)
	{
		light.pos = lightMat[3].xyz;
		#ifdef THIS_attenuated
		float d = length(p - light.pos);
		float start = THIS_attenuationstart;
		float end = THIS_attenuationend;
		if (d > end) {
			light.color = vec3(0.);
		} else if (d > start) {
			light.color *= (1 - smoothstep(start, end, d));
		}
		#endif
	}
	#elif defined(THIS_lighttype_distant)
	// not sure if this is correct
	light.pos = p - (vec3(0, 1, 0) * mat3(lightMat));
	#else
	#error unsupportedLightType
	#endif
	return light;
}
