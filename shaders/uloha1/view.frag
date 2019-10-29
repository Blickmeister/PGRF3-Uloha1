#version 150
out vec4 outColor; // output from the fragment shader
in vec3 color;
in vec3 normal_IO; // nevim esi ma byt in nebo out, spis in
in vec3 lightDir;
uniform sampler2D textureID;
in vec2 posIO;

void main() {
    float cosAlpha = max(0,dot(normal_IO, normalize(lightDir)));
    //outColor = vec4(1.0, 1.0, 1.0, 1.0);
    //outColor = vec4(color, 1.0);
    outColor = vec4(vec3(cosAlpha),1.0);
    outColor = vec4(texture(textureID,posIO).rgb,1.0);
}

