#version 150
out vec4 outColor;// output from the fragment shader
uniform sampler2D textureID;// ukazatel textury pro vykreslení
uniform sampler2D textureDepth;// ukazatel textury pro poměťovou hloubku textury
uniform mat4 matMVPLight;// matice MVP transformace z pohledu zdroje světla
uniform int objectType;// typ objektu
uniform int lightModelType;// typ světelného modelu
uniform int outcolorType;// způsob výpočtu výsledné barvy
uniform bool attenuation;
in vec2 posIO;// pozice do textury z VS
in vec4 objPos;// pozice z VS
in vec3 normalIO;// normála z VS
in vec3 lightDir;// směr světla z VS
in vec3 viewDir;// pohledový vektor z VS
in float intensity;// difúzní složka ve vrcholech
in float dist; // vzdálenost světla od objektu
uniform vec3 spotDir; // směr svícení

// koeficienty útlumu
const float constantAttenuation = 1.5;
const float linearAttenuation = 0.6;
const float quadraticAttenuation = 0.4;

void main() {

    // TODO mozna nejde světlo :))

    // shadow map
    // transformace z pohledu zdroje světla
    vec4 shadowCoord = matMVPLight* vec4(objPos.xyz, 1.0);
    // přepočet do souřadnic textury + bias
    vec3 texCoord = shadowCoord.xyz/shadowCoord.w*0.5+0.5;
    // odstranění akné
    float bias = 0.0005 * tan(acos(dot(normalize(normalIO), normalize(lightDir))));
    texCoord.z = texCoord.z - bias;

    vec4 finalColor;

    // rozdělění výpočtu barevných složek
    if (lightModelType == 1) { // difúzní složka pro osvětlení perVertex
        //float cosAlpha = max(0, dot(normalize(normalIO), normalize(lightDir)));
        //finalColor = vec4(vec3(cosAlpha), 1.0);
        // skokové obarvení pro ilustraci rozdílu mezi per vertex a per pixel
        if (intensity>0.95) finalColor=vec4(1.0, 0.5, 0.5, 1.0);
        else if (intensity>0.8) finalColor=vec4(0.6, 0.3, 0.3, 1.0);
        else if (intensity>0.5) finalColor=vec4(0.0, 0.0, 0.3, 1.0);
        else if (intensity>0.25) finalColor=vec4(0.4, 0.2, 0.2, 1.0);
        else finalColor=vec4(0.2, 0.1, 0.1, 1.0);

    } else if (lightModelType == 2) { // difúzní složka pro osvětlení perPixel

        // výpočet difúzní složky na základě interpolovaných hodnot
        float intensity = dot(normalize(lightDir), normalize(normalIO));
        // skokové obarvení pro ilustraci rozdílu mezi per vertex a per pixel
        if (intensity>0.95) finalColor=vec4(1.0, 0.5, 0.5, 1.0);
        else if (intensity>0.8) finalColor=vec4(0.6, 0.3, 0.3, 1.0);
        else if (intensity>0.5) finalColor=vec4(0.0, 0.0, 0.3, 1.0);
        else if (intensity>0.25) finalColor=vec4(0.4, 0.2, 0.2, 1.0);
        else finalColor=vec4(0.2, 0.1, 0.1, 1.0);

    } else if (lightModelType == 0) { // Blinn-Phongův osvětlovací model
        // ambientní složka
        vec4 ambient = vec4(0.2, 0, 0, 1);

        // difúzní složka
        float NdotL = max(0, dot(normalize(normalIO), normalize(lightDir)));
        vec4 diffuse = vec4(NdotL*vec3(1.0), 1);

        // zrcadlová složka
        vec3 halfVector = normalize(normalize(lightDir)+normalize(viewDir));
        float NdotH = dot(normalize(normalIO), halfVector);
        vec4 specular = vec4(pow(NdotH, 16)*vec3(1.0), 1);

        if (attenuation) {
            // výpočet útlumu světla
            float att = 1.0/(constantAttenuation + linearAttenuation * dist + quadraticAttenuation * (dist * dist));
            // výsledná barva
            finalColor = ambient + att*(diffuse + specular);
        } else {
            // výsledná barva Blinn-Phongova modelu
            finalColor = ambient + diffuse + specular;
        }
    }

    // barva světelného zdroje
    if (objectType == 2 || objectType == 10) {
        outColor = vec4(1.0);

    } else if (lightModelType == 0) { // pro Blinn-Phong model
        // výpočet kuželu a nastavení velikosti kužele
        float spotEffect =  max(dot(normalize(spotDir), normalize(-lightDir)), 0);
        float spotCutOff = 0.05;
        if (spotEffect > spotCutOff) {
            // je v kuželu světla

            if (texture(textureDepth, texCoord.xy).z < texCoord.z) {
                // je ve stínu

                // rozdělení dle zvoleného způsobu obarvení
                if (outcolorType == 0) {
                    // textura
                    outColor = vec4(0.1) * vec4(texture(textureID, posIO).rgb, 1.0);
                } else if (outcolorType == 1) {
                    // pozice
                    outColor = vec4(0.1) * vec4(objPos.xyz, 1.0);
                } else if (outcolorType == 2) {
                    // normála
                    outColor = vec4(0.1) * vec4(normalize(normalIO), 1.0);
                } else if (outcolorType == 3) {
                    // pozice do textury
                    outColor = vec4(0.1) * vec4(posIO, 0, 1.0);
                } else if (outcolorType == 4) {
                    // barva červená
                    outColor = vec4(0.1) * vec4(1, 0, 0, 1);
                } else if (outcolorType == 5) {
                    // barva zelená
                    outColor = vec4(0.1) * vec4(0, 1, 0, 1);
                } else {
                    // barva modrá
                    outColor = vec4(0.1) * vec4(0, 0, 1, 1);
                }
            } else {
                // není ve stínu

                // rozdělení dle zvoleného způsobu obarvení
                if (outcolorType == 0) {
                    // textura
                    outColor = vec4(texture(textureID, posIO).rgb, 1.0) * finalColor;
                } else if (outcolorType == 1) {
                    // pozice
                    outColor = vec4(objPos.xyz, 1.0) * finalColor;
                } else if (outcolorType == 2) {
                    // normála
                    outColor = vec4(normalize(normalIO), 1.0) * finalColor;
                } else if (outcolorType == 3) {
                    // pozice do textury
                    outColor = vec4(posIO, 0, 1.0) * finalColor;
                } else if (outcolorType == 4) {
                    // barva červená
                    outColor = vec4(1, 0, 0, 1) * finalColor;
                } else if (outcolorType == 5) {
                    // barva zelená
                    outColor = vec4(0, 1, 0, 1) * finalColor;
                } else {
                    // barva modrá
                    outColor = vec4(0, 0, 1, 1) * finalColor;
                }
            }
        } else {
            // není v kuželu světla - pouze ambientní složka
            outColor = vec4(0.2, 0, 0, 1);

        }
    } else { // pro demonstraci rozdílu mezi per vertex a per pixel
        outColor = vec4(finalColor);
    }
}

