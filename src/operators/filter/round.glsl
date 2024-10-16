ReturnT thismap(CoordT p, ContextT ctx) {
	ReturnT res = inputOp1(p, ctx);
	if (IS_FALSE(THIS_Enable)) { return res; }
	#ifdef THIS_EXPOSE_sdf
	THIS_sdf = res;
	#endif
	float amt = THIS_Amount;
	#ifdef THIS_HAS_INPUT_amountField
	amt += inputOp_amountField(p, ctx);
	#endif
	#ifdef THIS_RETURN_TYPE_Sdf
	res.x -= amt;
	#else
	res -= amt;
	#endif
	return res;
}