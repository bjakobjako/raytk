// raytkParticles.glsl

struct Particle {
	vec3 pos;
	vec3 dir;
	vec3 vel;
	vec3 angVel;
	vec3 accel;
	vec3 angAccel;
	float age;
	float life;
	int state;
	uint id;
};

const int P_STATE_DEAD = 0;
const int P_STATE_ALIVE = 1;
const float P_LIFE_INFINITE = -1.0;

Particle createParticle(vec3 p, vec3 d) {
	return Particle(
		p, d, vec3(0.), vec3(0.), vec3(0.), vec3(0.), 0., 0., P_STATE_DEAD, 0
	);
}
Particle createParticle() { return createParticle(vec3(0.), vec3(0.)); }
bool isAlive(Particle part) {
	return part.state == P_STATE_ALIVE;
}

vec4 getParticleStateVec(Particle part) {
	return vec4(part.age, part.life, float(part.state), float(part.id));
}
void setParticleStateVec(inout Particle part, vec4 state) {
	part.age = state.x;
	part.life = state.y;
	part.state = int(round(state.z));
	part.id = uint(round(state.w));
}

void initDefVal(out Particle val) {
	val = createParticle(vec3(0.), vec3(0.));
}

struct ParticleContext {
	Context context;
	Particle particle;
	ivec2 dataPos;
};

ParticleContext createParticleContext(Context ctx, Particle part, ivec2 dataPos) {
	return ParticleContext(ctx, part, dataPos);
}
