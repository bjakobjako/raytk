// Based on Spiral Tiling by Knightly
// https://www.shadertoy.com/view/ls2GRz

ReturnT thismap(CoordT p, ContextT ctx) {
	p = vec3(p.THIS_PLANE_P1, p.THIS_PLANE_P2, p.THIS_AXIS);
	vec2 c = vec2(THIS_Branches, THIS_Bend);
	float r=length(p.xy);
	vec2 f=vec2(log(r),atan(p.y,p.x))*0.5/PI;//Log-polar coordinates
	float d=f.y*c.x-f.x*c.y;//apply rotation and scaling.
	d=fract(d);//"fold" d to [0,1] interval
	d=(d-0.5)*2.*PI*r/length(c);//(0.5-abs(d-0.5))*2.*PI*r/length(c);
	
	vec2 pp=vec2(d,p.z);
	//float a=20.*sin(3.*iTime)*f.x;//twisting angle
	float a=THIS_Twist*f.x;
	mat2 m=mat2(vec2(cos(a),-sin(a)), vec2(sin(a),cos(a)));
	pp=m*pp;//apply twist
	pp=abs(pp);
	#pragma r:if inputOp_crossSection_RETURN_TYPE_Sdf
	Sdf res = inputOp_crossSection(pp.xy, ctx);
	return res;
	#pragma r:elif inputOp_crossSection_RETURN_float
	return createSdf(0.9 * (inputOp_crossSection(pp.xy, ctx) - THIS_Thickness));
	#pragma r:else
	float e = THIS_Exponent;//superquadric param
	float res= 0.9*(pow(pow(pp.x,e)+pow(pp.y,e),1./e)-THIS_Thickness*r);//distance have to be scaled down because this is just an approximation.
	return createSdf(res);
	#pragma r:endif
}