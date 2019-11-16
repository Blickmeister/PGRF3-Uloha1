#version 150
in vec4 pos; // pozice z VS
out vec4 outColor; // output from the fragment shader
void main() {
	// výpočet výsledné barvy
	outColor = vec4(vec3(pos.z/pos.w), 1.0);
	//	outColor = vec4(vec3(gl_FragCoord.z), 1.0);
}

