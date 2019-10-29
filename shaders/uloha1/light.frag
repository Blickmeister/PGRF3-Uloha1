#version 150
out vec4 outColor; // output from the fragment shader
in vec4 pos;
void main() {

	outColor = vec4(0,0,pos.z/pos.w,1.0);
}

