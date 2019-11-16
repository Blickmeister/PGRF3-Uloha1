#version 150
out vec4 outColor; // output from the fragment shader
uniform sampler2D textureID; // ukazatel textury pro vykreslení
uniform sampler2D textureDepth; // ukazatel textury pro poměťovou hloubku textury
uniform mat4 matMVPLight; // matice MVP transformace z pohledu zdroje světla
uniform int objectType; // typ objektu
uniform int lightModelType; // typ světelného modelu
uniform int outcolorType; // způsob výpočtu výsledné barvy
in vec2 posIO; // pozice do textury z VS
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
        finalColor = vec4(vec3(cosAlpha), 1.0);
    }

    // TODO nejde světlo :))
    if(lightModelType == 0) {
        // phongův osvětlovací model
        // ambientní složka
        vec4 ambient = vec4(0.2,0,0,1);

        // difúzní složka
        float NdotL = max(0,dot(normalize(normalIO), normalize(lightDir)));
        vec4 diffuse = vec4(NdotL*vec3(1.0),1);

        // zrcadlová složka
        vec3 halfVector = normalize(normalize(lightDir)+normalize(viewDir));
        float NdotH = dot(normalize(normalIO), halfVector);
        vec4 specular = vec4(pow(NdotH, 16)*vec3(1.0),1);

        //light parameters declaration
        /*float ambientStrength = 0.2;
        float specularStrength = 0.5;
        vec3 lightColor = vec3(1.0);

        //ambient
        vec3 ambient = ambientStrength * lightColor;

        //difuse
        float diff = max(dot(normalize(normalIO), normalize(lightDir)), 0.0);
        vec3 diffuse = diff * lightColor;

        //specular
        //phong
        //vec3 reflectDir = reflect(-lightDir, vertNormal);
        //float spec = pow(max(dot(viewDir, reflectDir), 0.0), 8);
        //blinn-phong
        vec3 halfwayDir = normalize(lightDir + viewDir);
        float spec = pow(max(dot(normalize(normalIO), normalize(halfwayDir)), 0.0), 64);
        vec3 specular = specularStrength * spec * lightColor;*/


        // výsledná barva phongova modelu
        finalColor = vec4(vec3(ambient + diffuse + specular),1.0);
    }
    // barva světelného zdroje
    if(objectType == 2) {
        outColor = vec4(1.0);

    } else if (texture(textureDepth, texCoord.xy).z < texCoord.z){
        // je ve stínu
        // rozdělení dle zvoleného způsobu obarvení
        if(outcolorType == 0) {
            // textura
            outColor = vec4(0.1) * vec4(texture(textureID,posIO).rgb, 1.0);
        } else if(outcolorType == 1) {
            // pozice
            outColor = vec4(0.1) * vec4(objPos.xyz, 1.0);
        } else if(outcolorType == 2) {
            // normála
            outColor = vec4(0.1) * vec4(normalize(normalIO), 1.0);
        } else if(outcolorType == 3) {
            // pozice do textury
            outColor = vec4(0.1) * vec4(posIO, 0, 1.0);
        } else if(outcolorType == 4) {
            // barva červená
            outColor = vec4(0.1) * vec4(1,0,0,1);
        } else if(outcolorType == 5) {
            // barva zelená
            outColor = vec4(0.1) * vec4(0,1,0,1);
        } else {
            // barva modrá
            outColor = vec4(0.1) * vec4(0,0,1,1);
        }
    } else{
        // není ve stínu
        // rozdělení dle zvoleného způsobu obarvení
        if(outcolorType == 0) {
            // textura
            outColor = vec4(texture(textureID,posIO).rgb, 1.0) * finalColor;
        } else if(outcolorType == 1) {
            // pozice
            outColor = vec4(objPos.xyz, 1.0) * finalColor;
        } else if(outcolorType == 2) {
            // normála
            outColor = vec4(normalize(normalIO), 1.0) * finalColor;
        } else if(outcolorType == 3) {
            // pozice do textury
            outColor = vec4(posIO, 0, 1.0) * finalColor;
        } else if(outcolorType == 4) {
            // barva červená
            outColor = vec4(1,0,0,1) * finalColor;
        } else if(outcolorType == 5) {
            // barva zelená
            outColor = vec4(0,1,0,1) * finalColor;
        } else {
            // barva modrá
            outColor = vec4(0,0,1,1) * finalColor;
        }
    }
}

