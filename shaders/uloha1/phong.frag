#version 150
out vec4 outColor; // output from the fragment shader
uniform sampler2D textureID;
uniform sampler2D textureDepth;
uniform mat4 matMVPlight;
uniform int mode;
in vec2 posIO;
in vec4 objPos;
in vec3 normal;
in vec3 lightDir;
in vec3 viewDir;

void main() {

    // phongův osvětlovací model
    // ambientní složka
    vec4 ambient = vec4(0.2,0,0,1);

    // difúzní složka
    float NdotL = max(0,dot(normalize(normal), normalize(lightDir)));
    vec4 diffuse = vec4(NdotL*vec3(0,0.8,0),1);

    // zrcadlová složka
    vec3 halfVector = normalize(normalize(lightDir)+normalize(viewDir));
    float NdotH = dot(normalize(normal), halfVector);
    vec4 specular = vec4(pow(NdotH, 16)*vec3(0,0,0.8),1);

    // výsledná barva phongova modelu
    vec4 finalColor = ambient +diffuse +specular;

    // transformace z pohledu zdroje světla
    vec4 shadowCoord = matMVPlight* vec4(objPos.xyz, 1.0);
    // přepočet do souřadnic textury + bias
    vec3 texCoord = shadowCoord.xyz/shadowCoord.w*0.5+0.5;
    // odstranění akné
    float bias = 0.0005 * tan(acos(dot(normalize(normal),normalize(lightDir))));
    texCoord.z = texCoord.z - bias;

    // barva světelného zdroje
    if(mode==2) {
        outColor = vec4(1.0);
    }
    // porovnání s hloubkovou mapou
    else if (texture(textureDepth, texCoord.xy).z < texCoord.z){
        // je ve stínu
        outColor = ambient * vec4(texture(textureID,posIO).rgb, 1.0);
    } else{
        // není ve stínu
        outColor = vec4(texture(textureID,posIO).rgb, 1.0) * finalColor;
    }
}

