
float cmb_simpleUnion(float res1, float res2) { return min(res1, res2); }
Sdf cmb_simpleUnion(Sdf res1, Sdf res2) { return (res1.x<res2.x)? res1:res2; }

float cmb_simpleIntersect(float res1, float res2) { return max(res1, res2); }
Sdf cmb_simpleIntersect(Sdf res1, Sdf res2) { return (res1.x>res2.x) ? res1 : res2; }

float cmb_simpleDiff(float res1, float res2) { return max(-res2, res1); }
Sdf cmb_simpleDiff(Sdf res1, Sdf res2) {
	Sdf res = res1;
	res.x = max(-res2.x, res1.x);
	return res;
}

float cmb_smoothUnion(float res1, float res2, float h, float r) {
	return mix(res2, res1, h) - r*h*(1.0-h);
}
Sdf cmb_smoothUnion(Sdf res1, Sdf res2, float r) {
	float h = smoothBlendRatio(res1.x, res2.x, r);
	float resx = mix(res2.x, res1.x, h) - r*h*(1.0-h);
	res1.x = resx;
	blendInSdf(res1, res2, 1. - h);
	return res1;
}

float cmb_smoothIntersect(float res1, float res2, float r) {
	float h = clamp(0.5 - 0.5*(res2-res1)/r, 0., 1.);
	return mix(res2, res1, h) + r*h*(1.0-h);
}
Sdf cmb_smoothIntersect(Sdf res1, Sdf res2, float r) {
	Sdf res = res1;
	float h = clamp(0.5 - 0.5*(res2.x-res1.x)/r, 0., 1.);
	res.x = mix(res2.x, res1.x, h) + r*h*(1.0-h);
	blendInSdf(res1, res2, h);
	return res;
}

float cmb_smoothDiff(float res1, float res2, float r) { return cmb_smoothIntersect(res1, -res2, r); }
Sdf cmb_smoothDiff(Sdf res1, Sdf res2, float r) {
	res2.x *= -1.;
	return cmb_smoothIntersect(res1, res2, r);
}

float cmb_roundUnion(float res1, float res2, float r) { return fOpUnionRound(res1, res2, r); }
Sdf cmb_roundUnion(Sdf res1, Sdf res2, float r) {
	float h = smoothBlendRatio(res1.x, res2.x, r);
	res1.x = fOpUnionRound(res1.x, res2.x, r);
	blendInSdf(res1, res2, 1.0 - h);
	return res1;
}

float cmb_roundIntersect(float res1, float res2, float r) { return fOpIntersectionRound(res1, res2, r); }
Sdf cmb_roundIntersect(Sdf res1, Sdf res2, float r) {
	float h = smoothBlendRatio(res1.x, res2.x, r);
	fOpIntersectionRound(res1.x, res2.x, r);
	blendInSdf(res1, res2, 1.0 - h);
	return res1;
}

float cmb_roundDiff(float res1, float res2, float r) { return fOpDifferenceRound(res1, res2, r); }
Sdf cmb_roundDiff(Sdf res1, Sdf res2, float r) {
	float h = smoothBlendRatio(res1.x, res2.x, r);
	res1.x = fOpDifferenceRound(res1.x, res2.x, r);
	blendInSdf(res1, res2, 1.0 - h);
	return res1;
}

float cmb_chamferUnion(float res1, float res2, float r) { return fOpUnionChamfer(res1, res2, r); }
Sdf cmb_chamferUnion(Sdf res1, Sdf res2, float r) {
	float h = smoothBlendRatio(res1.x, res2.x, r);
	res1.x = fOpUnionChamfer(res1.x, res2.x, r);
	blendInSdf(res1, res2, 1.0 - h);
	return res1;
}

float cmb_chamferIntersect(float res1, float res2, float r) { return fOpIntersectionChamfer(res1, res2, r); }
Sdf cmb_chamferIntersect(Sdf res1, Sdf res2, float r) {
	float h = smoothBlendRatio(res1.x, res2.x, r);
	res1.x = fOpIntersectionChamfer(res1.x, res2.x, r);
	blendInSdf(res1, res2, 1.0 - h);
	return res1;
}

float cmb_chamferDiff(float res1, float res2, float r) { return fOpDifferenceChamfer(res1, res2, r); }
Sdf cmb_chamferDiff(Sdf res1, Sdf res2, float r) {
	float h = smoothBlendRatio(res1.x, res2.x, r);
	res1.x = fOpDifferenceChamfer(res1.x, res2.x, r);
	blendInSdf(res1, res2, 1.0 - h);
	return res1;
}

float cmb_stairUnion(float res1, float res2, float r, float n, float o) {
	float s = r/n;
	float u = res2-r;
	return min(min(res1,res2), 0.5 * (u + res1 + abs ((mod (u - res1 + s + o, 2 * s)) - s)));
}
Sdf cmb_stairUnion(Sdf res1, Sdf res2, float r, float n, float o) {
	float h = smoothBlendRatio(res1.x, res2.x, r);
	res1.x = cmb_stairUnion(res1.x, res2.x, r, n, o);
	blendInSdf(res1, res2, 1.0 - h);
	return res1;
}

float cmb_stairIntersect(float res1, float res2, float r, float n, float o) {
	return -cmb_stairUnion(-res1, -res2, r, n, o);
}
Sdf cmb_stairIntersect(Sdf res1, Sdf res2, float r, float n, float o) {
	float h = smoothBlendRatio(res1.x, res2.x, r);
	res1.x = cmb_stairIntersect(res1.x, res2.x, r, n, o);
	blendInSdf(res1, res2, 1.0 - h);
	return res1;
}

float cmb_stairDiff(float res1, float res2, float r, float n, float o) {
	return -cmb_stairUnion(-res1, res2, r, n, o);
}
Sdf cmb_stairDiff(Sdf res1, Sdf res2, float r, float n, float o) {
	float h = smoothBlendRatio(res1.x, res2.x, r);
	res1.x = fOpDifferenceStairs(res1.x, res2.x, r, n, o);
	blendInSdf(res1, res2, 1.0 - h);
	return res1;
}

float cmb_columnUnion(float res1, float res2, float r, float n, float o) {
	if ((res1 < r) && (res2 < r)) {
		vec2 p = vec2(res1, res2);
		float columnradius = r*sqrt(2)/((n-1)*2+sqrt(2));
		pR45(p);
		p.x -= sqrt(2)/2*r;
		p.x += columnradius*sqrt(2);
		if (mod(n,2) == 1) {
			p.y += columnradius;
		}
		// At this point, we have turned 45 degrees and moved at a point on the
		// diagonal that we want to place the columns on.
		// Now, repeat the domain along this direction and place a circle.
		p.y += o;
		pMod1(p.y, columnradius*2);
		float result = length(p) - columnradius;
		result = min(result, p.x);
		result = min(result, res1);
		return min(result, res2);
	} else {
		return min(res1, res2);
	}
}

Sdf cmb_columnUnion(Sdf res1, Sdf res2, float r, float n, float o) {
	float h = smoothBlendRatio(res1.x, res2.x, r);
	res1.x = cmb_columnUnion(res1.x, res2.x, r, n, o);
	blendInSdf(res1, res2, 1.0 - h);
	return res1;
}

float cmb_columnDiff(float res1, float res2, float r, float n, float o) {
	res1 = -res1;
	float m = min(res1, res2);
	//avoid the expensive computation where not needed (produces discontinuity though)
	if ((res1 < r) && (res2 < r)) {
		vec2 p = vec2(res1, res2);
		float columnradius = r*sqrt(2)/n/2.0;
		columnradius = r*sqrt(2)/((n-1)*2+sqrt(2));

		pR45(p);
		p.y += columnradius;
		p.x -= sqrt(2)/2*r;
		p.x += -columnradius*sqrt(2)/2;

		if (mod(n,2) == 1) {
			p.y += columnradius;
		}
		p.y += o;
		pMod1(p.y,columnradius*2);

		float result = -length(p) + columnradius;
		result = max(result, p.x);
		result = min(result, res1);
		return -min(result, res2);
	} else {
		return -m;
	}
}
Sdf cmb_columnDiff(Sdf res1, Sdf res2, float r, float n, float o) {
	float h = smoothBlendRatio(res1.x, res2.x, r);
	res1.x = cmb_columnDiff(res1.x, res2.x, r, n, o);
	blendInSdf(res1, res2, 1.0 - h);
	return res1;
}

float cmb_columnIntersect(float res1, float res2, float r, float n, float o) {
	return cmb_columnDiff(res1,-res2,r, n, o);
}
Sdf cmb_columnIntersect(Sdf res1, Sdf res2, float r, float n, float o) {
	float h = smoothBlendRatio(res1.x, res2.x, r);
	res1.x = cmb_columnIntersect(res1.x, res2.x, r, n, o);
	blendInSdf(res1, res2, 1.0 - h);
	return res1;
}
