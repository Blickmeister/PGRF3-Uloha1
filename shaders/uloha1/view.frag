#version 150
out vec4 outColor; // output from the fragment shader
uniform sampler2D textureID;
uniform sampler2D textureDepth;
uniform mat4 matMVPlight;
uniform int mode;
in vec2 posIO;
in vec4 objPos;
in vec3 normalIO;
in vec3 lightDir;

void main() {

    // shadow map
    // transformace z pohledu zdroje světla
    vec4 shadowCoord = matMVPlight* vec4(objPos.xyz, 1.0);
    // přepočet do souřadnic textury + bias
    vec3 texCoord = shadowCoord.xyz/shadowCoord.w*0.5+0.5;
    // odstranění akné
    float bias = 0.0005 * tan(acos(dot(normalize(normalIO),normalize(lightDir))));
    texCoord.z = texCoord.z - bias;

    // výpočet osvětlení - difúzní složka
    float cosAlpha = max(0,dot(normalIO, normalize(lightDir)));
    vec4 finalColor = vec4(vec3(cosAlpha*2),1.0);

    // barva světelného zdroje
    if(mode == 2) {
        outColor = vec4(1.0);

    } else if (texture(textureDepth, texCoord.xy).z < texCoord.z){
        // je ve stínu
        outColor = vec4(0.1) * vec4(texture(textureID,posIO).rgb, 1.0);
    } else{
        // není ve stínu
        outColor = vec4(texture(textureID,posIO).rgb, 1.0) * finalColor;
    }
}

