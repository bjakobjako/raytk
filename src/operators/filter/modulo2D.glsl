ReturnT thismap(CoordT p, ContextT ctx) {
	vec2 q = p.THIS_PLANE;
	vec2 size = THIS_Size;
	#ifdef THIS_HAS_INPUT_sizeField
	{
		#if defined(inputOp_sizeField_COORD_TYPE_vec2)
		vec2 q1 = q;
		#else
		inputOp_sizeField_CoordT q1 = inputOp_sizeField_asCoordT(p);
		#endif
		size *= fillToVec2(inputOp_sizeField(q1, ctx));
	}
	#endif
	vec2 halfsize = size * 0.5;

	vec2 sh = THIS_Shift;
	#ifdef THIS_HAS_INPUT_shiftField
	{
		#if defined(inputOp_shiftField_COORD_TYPE_vec2)
		vec2 q1 = q;
		#else
		inputOp_shiftField_CoordT q1 = inputOp_shiftField_asCoordT(p);
		#endif
		sh += fillToVec2(inputOp_shiftField(q1, ctx));
	}
	#endif
	q += sh;
	vec2 c = floor((q + halfsize)/size);
	q = mod(q + halfsize, size) - halfsize;
	#if defined(THIS_Limittype_both) || defined(THIS_Limittype_start)
	vec2 start = THIS_Limitstart + THIS_Limitoffset;
	if (c.x < start.x) applyModLimit(q.x, c.x, size.x, start.x);
	if (c.y < start.y) applyModLimit(q.y, c.y, size.y, start.y);
	#endif
	#if defined(THIS_Limittype_both) || defined(THIS_Limittype_stop)
	vec2 stop = THIS_Limitstop + THIS_Limitoffset;
	if (c.x > stop.x) applyModLimit(q.x, c.x, size.x, stop.x);
	if (c.y > stop.y) applyModLimit(q.y, c.y, size.y, stop.y);
	#endif

	#if defined(THIS_Mirrortype_mirror)
	q *= mod(c,vec2(2))*2 - vec2(1);
	#elif defined(THIS_Mirrortype_grid)
	q *= mod(c,vec2(2))*2 - vec2(1);
	q -= halfsize;
	if (q.x > q.y) q.xy = q.yx;
	c = floor(c/2);
	#endif

	#if defined(THIS_Iterationtype_cellcoord)
	setIterationCell(ctx, c);
	#elif defined(THIS_Iterationtype_tiledquadrant)
	setIterationIndex(ctx, quadrantIndex(ivec2(mod(ivec2(c), 2))));
	#elif defined(THIS_Iterationtype_alternatingcoord)
	setIterationCell(ctx, mod(c, 2.));
	#endif
	// offset field can use iteration
	vec2 o = THIS_Offset;
	#ifdef THIS_HAS_INPUT_offsetField
	{

		#if defined(inputOp_offsetField_COORD_TYPE_vec2)
		vec2 q1 = q;
		#else
		inputOp_offsetField_CoordT q1 = inputOp_offsetField_asCoordT(p);
		#endif
		o += fillToVec2(inputOp_offsetField(q1, ctx));
	}
	#else
	#endif
	p.THIS_PLANE = q - o;
	return inputOp1(p, ctx);
}