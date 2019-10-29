#version 150
in vec2 inPosition; // input from the vertex buffer
uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;
out vec4 pos;
//uniform mat4 matMV;

float getFValue(vec2 xy){
	return -(xy.x*xy.x*5+xy.y*xy.y*5);
}

vec3 getNormal(vec2 xy){
	float delta = 0.01;
	vec3 u = vec3(xy.x + delta, xy.y, getFValue(xy + vec2(delta,0)))
	- vec3(xy - vec2(delta,0), getFValue(xy + vec2(delta,0)));
	vec3 v = vec3(xy + vec2(0,delta), getFValue(xy + vec2(delta,0)))
	- vec3(xy - vec2(0,delta), getFValue(xy - vec2(0,delta)));
	return cross(u,v);
}


void main() {
	vec2 position = inPosition-0.5;

	float z = getFValue(position.xy);
	vec4 objectPos = vec4(position.x, z, position.y, 1.0);

	gl_Position = proj*view*model*objectPos;
	pos = proj*view*model*objectPos;
} 
