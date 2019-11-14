#version 150
out vec4 outColor; // output from the fragment shader
uniform sampler2D textureID; // ukazatel textury pro vykreslení
uniform sampler2D textureDepth; // ukazatel textury pro poměťovou hloubku textury
uniform mat4 matMVPLight; // matice MVP transformace z pohledu zdroje světla
uniform int objectType; // typ objektu
uniform int lightModelType;
in vec2 posIO;
in vec4 objPos; // pozice z VS
in vec3 normalIO; // normála z VS
in vec3 lightDir; // směr světla z VS
in vec3 viewDir; // pohledový vektor z VS

void main() {

    // shadow map
    // transformace z pohledu zdroje světla
    vec4 shadowCoord = matMVPLight* vec4(objPos.xyz, 1.0);
    // přepočet do souřadnic textury + bias
    vec3 texCoord = shadowCoord.xyz/shadowCoord.w*0.5+0.5;
    // odstranění akné
    float bias = 0.0005 * tan(acos(dot(normalize(normalIO),normalize(lightDir))));
    texCoord.z = texCoord.z - bias;

    vec4 finalColor;

    // výpočet osvětlení - difúzní složka pro osvětlení perPixel
    if(lightModelType == 1) {
        float cosAlpha = max(0, dot(normalize(normalIO), normalize(lightDir)));
        finalColor = vec4(vec3(cosAlpha*2), 1.0);
    }

    if(lightModelType == 0) {
        // phongův osvětlovací model
        // ambientní složka
        vec4 ambient = vec4(0.2,0,0,1);

        // difúzní složka
        float NdotL = max(0,dot(normalize(normalIO), normalize(lightDir)));
        vec4 diffuse = vec4(NdotL*vec3(0,0.8,0),1);

        // zrcadlová složka
        vec3 halfVector = normalize(normalize(lightDir)+normalize(viewDir));
        float NdotH = dot(normalize(normalIO), halfVector);
        vec4 specular = vec4(pow(NdotH, 16)*vec3(0,0,0.8),1);

        // výsledná barva phongova modelu
        finalColor = ambient +diffuse +specular;
    }
    // barva světelného zdroje
    if(objectType == 2) {
        outColor = vec4(1.0);

    } else if (texture(textureDepth, texCoord.xy).z < texCoord.z){
        // je ve stínu
        // TODO rozdělit outColor dle typu osvětlení
        outColor = vec4(0.1) * vec4(texture(textureID,posIO).rgb, 1.0);
    } else{
        // není ve stínu
        outColor = vec4(texture(textureID,posIO).rgb, 1.0) * finalColor;
    }
}

