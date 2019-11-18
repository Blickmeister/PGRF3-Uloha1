#version 150
out vec4 outColor; // output from the fragment shader
uniform sampler2D textureID;
uniform sampler2D textureDepth;
uniform mat4 matMVPLight;
uniform int objectType;
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
    vec4 shadowCoord = matMVPLight* vec4(objPos.xyz, 1.0);
    // přepočet do souřadnic textury + bias
    vec3 texCoord = shadowCoord.xyz/shadowCoord.w*0.5+0.5;
    // odstranění akné
    float bias = 0.0005 * tan(acos(dot(normalize(normal),normalize(lightDir))));
    texCoord.z = texCoord.z - bias;

    // barva světelného zdroje
    if(objectType==2) {
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

// ---------------------------- kopceni pro perV/perP

/*vec4 finalColor;

// rozdělění výpočtu barevných složek
if(lightModelType == 1) { // difúzní složka pro osvětlení perVertex
    //float cosAlpha = max(0, dot(normalize(normalIO), normalize(lightDir)));
    //finalColor = vec4(vec3(cosAlpha), 1.0);
    // skokové obarvení pro ilustraci rozdílu mezi per vertex a per pixel
    if (intensity>0.95) finalColor=vec4(1.0,0.5,0.5,1.0);
    else if (intensity>0.8) finalColor=vec4(0.6,0.3,0.3,1.0);
    else if (intensity>0.5) finalColor=vec4(0.0,0.0,0.3,1.0);
    else if (intensity>0.25) finalColor=vec4(0.4,0.2,0.2,1.0);
    else finalColor=vec4(0.2,0.1,0.1,1.0);

} else if(lightModelType == 2) { // difúzní složka pro osvětlení perPixel

// výpočet difúzní složky na základě interpolovaných hodnot
float intensity = dot(lightDir, normalIO);
// skokové obarvení pro ilustraci rozdílu mezi per vertex a per pixel
if (intensity>0.95) finalColor=vec4(1.0,0.5,0.5,1.0);
else if (intensity>0.8) finalColor=vec4(0.6,0.3,0.3,1.0);
else if (intensity>0.5) finalColor=vec4(0.0,0.0,0.3,1.0);
else if (intensity>0.25) finalColor=vec4(0.4,0.2,0.2,1.0);
else finalColor=vec4(0.2,0.1,0.1,1.0);

outColor = vec4(finalColor);*/
