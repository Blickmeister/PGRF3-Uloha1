#version 150
in vec2 inPosition; // input from the vertex buffer
uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;
out vec4 pos;

float getFValue(vec2 xy){
	return -(xy.x*xy.x*5+xy.y*xy.y*5);
}

void main() {
	vec2 position = inPosition-0.5;
	float z = getFValue(position.xy);
	vec4 objPos = vec4(position.x, position.y, z, 1.0);

	gl_Position = proj*view*model*objPos;
	pos = proj*view*model*objPos;
}
