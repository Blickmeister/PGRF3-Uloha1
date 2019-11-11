#version 150
in vec4 pos;
out vec4 outColor; // output from the fragment shader
void main() {

	outColor = vec4(vec3(pos.z/pos.w), 1.0);
	//	outColor = vec4(vec3(gl_FragCoord.z), 1.0);
}

