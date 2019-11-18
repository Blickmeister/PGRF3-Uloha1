#version 150
in vec2 inPosition; // input from the vertex buffer
uniform mat4 model; // modelová matice
uniform mat4 view; // pohledová matice
uniform mat4 proj; // projekční matice
uniform vec3 lightPos; // pozice světla
uniform vec3 viewPos; // pozice pozorovatele
uniform float time; // pro pohyb tělesa
uniform int objectType; // typ objektu
uniform int lightModelType; // typ světelného modelu
out vec2 posIO; // pozice do textury pro FS
out vec4 objPos; // výsledná pozice pro FS
out vec3 normalIO; // normála pro FS
out vec3 lightDir; // směr světla pro FS
out vec3 viewDir; // pohledový vektor pro FS
out float intensity; // difúzní složka ve vrcholech pro FS
out vec3 vertColor; // TODO zatim k hovnu nwm co s nim, mozna pryc

// získání z hodnoty - pro rovinnou podložku a první těleso v kartézských souřadnicích
float getFValue(vec2 vec){
    if (objectType==0) {
        return 0;
    } else {
        return -(vec.x*vec.x*5+vec.y*vec.y*5);
    }
}

// druhý objekt v kartézských souřadnicích
vec3 getCone(vec2 vec) {
    float t = vec.x * 1;
    float s = vec.y * 2 * 3.14;

    float x = t*cos(s);
    float y = t*sin(s);
    float z = t;

    return vec3(x, y, z);
}

// první objekt ve sférických souřadnicích
vec3 getElephantHead(vec2 vec) {
    // nastavení parametrů
    float az = vec.x * 2 * 3.14; // azimut
    float ze = vec.y * 3.14; // zenit
    float r = 3+cos(4*az); // poloměr

    // přepočet na kartézské souřadnice
    float x = r*cos(az)*cos(ze);
    float y = r*sin(az)*cos(ze);
    float z = r*sin(ze);

    return vec3(x, y, z);
}

// druhý objekt ve sférických souřadnicích
vec3 getMyBattleStation(vec2 vec) {
    float az = vec.x * 1.5 * 3.14;
    float ze = vec.y * 3.14;
    float r = 1+2*sin(4*ze);

    float x = r*cos(az)*cos(ze);
    float y = r*sin(az)*cos(ze);
    float z = r*sin(ze);

    return vec3(x, y, z);
}

// první objekt v cylindrických souřadnicích
vec3 getSombrero(vec2 vec) {
    float az = vec.x * 2 * 3.14; //s - theta
    float r = vec.y * 2 * 3.14; //t - r
    float v = 2 * sin(r); // z - v

    float x = r * cos(az);
    float y = r * sin(az);
    float z = v;

    return vec3(x, y, z);
}

// druhý objekt v cylindrických souřadnicích (spirála se "zhušťuje" díky uniform proměnné time)
vec3 getSpiral(vec2 vec) {
    // závora aby se spirála nezhušťovala donekonečna
    float inc = time;
    if(inc > 10) {
        inc = 10;
    }
    float az = vec.y * 2 * 3.14 * inc; //s - theta
    float r = vec.y * 2 * 3.14; //t - r
    float v = vec.x * 12; // z

    float x = v * sin(az);
    float y = v * cos(az);
    float z = r;

    return vec3(x, y, z);
}

// výpočet koule - reprezentace zdroje světla
vec3 getSphere(vec2 vec) {
    float az = vec.x * 3.14 *2;
    float ze = vec.y * 3.14;
    float r = 1;

    float x = r*cos(az)*cos(ze);
    float y = r*sin(az)*cos(ze);
    float z = r*sin(ze);

    return vec3(x, y, z);
}

// výpočet fazolky (sférické souřadnice) pro demonstraci rozdílu mezi per vertex a per pixel
vec3 getBean(vec2 vec) {
    float az = vec.x * 3.14 *2;
    float ze = vec.y * 3.14;
    float r = 1;

    float x = r*cos(az)*cos(ze);
    float y = 2 * r*sin(az)*cos(ze);
    float z = 0.5 * r*sin(ze);

    return vec3(x, y, z);
}

// výpočet normály
vec3 getNormal(vec2 xy){
    float delta = 0.01;
    vec3 u = vec3(xy.x + delta, xy.y, getFValue(xy + vec2(delta,0)))
    - vec3(xy - vec2(delta,0), getFValue(xy - vec2(delta,0)));
    vec3 v = vec3(xy + vec2(0,delta), getFValue(xy + vec2(0,delta)))
    - vec3(xy - vec2(0,delta), getFValue(xy - vec2(0,delta)));
    return cross(u,v);
}

void main() {
    posIO = inPosition;
    vec2 position = inPosition -  0.5;

    // rozdělení objektů podle zvoleného modelu osvětlení
    if(lightModelType == 0) { // Blinn-Phong

        // rozdělení objektů dle vytvoření - výpočet z || xyz
        if (objectType < 2) {
            // výpočet z hodnoty
            float z = getFValue(position.xy);
            objPos = vec4(position.x, position.y, z, 1.0);
        } else if (objectType == 2) {
            // výpočet xyz hodnot
            objPos = vec4(getSphere(position), 1.0); // světlo
        } else if (objectType == 3) {
            objPos = vec4(getCone(position), 1.0); // přesýpací hodiny
        } else if (objectType == 4) {
            objPos = vec4(getElephantHead(position), 1.0); // sloní hlava
        } else if (objectType == 5){
            objPos = vec4(getMyBattleStation(position), 1.0); // moje bitevní stanice
        } else if (objectType == 6){
            objPos = vec4(getSombrero(inPosition), 1.0); // sombrero
        } else if (objectType == 7) {
            objPos = vec4(getSpiral(position), 1.0); // spirála
        }
    } else { // Per vertex/Per pixel
        if(objectType == 8) { // 1. fazolka
            objPos = vec4(getBean(position), 1.0);
        } else if(objectType == 9) { // 2. fazolka
            objPos = vec4(getBean(position), 1.0);
        } else if(objectType == 10) { // světlo
            objPos = vec4(getSphere(position), 1.0);
        }
    }
    objPos = model * objPos; // modelová transformace

    vec3 normal;
    // rozdělění výpočtu normály a vektorů světla dle zvoleného modelu osvětlení
    if(lightModelType == 0) { // Blinn-Phong
        // výpočet vektoru směru světla
        lightDir = normalize((mat3(view) * lightPos).xyz - (view * objPos).xyz);
        // výpočet vektoru pohledu (pouze v případě phonga)
        viewDir = normalize((mat3(view) * viewPos).xyz - (view * objPos).xyz);
        // výpočet normály
        normal = normalize(getNormal(position.xy)); // normalizace a výpočet normály
        normal = inverse(transpose(mat3(view * model))) * normal; // transformace normály
        normalIO = normal;

    } else if(lightModelType == 1) { // per vertex
        normal = normalize(getNormal(position.xy)); // normalizace a výpočet normály
        normal = inverse(transpose(mat3(view * model))) * normal; // transformace normály
        // výpočet vektoru směru světla
        lightDir = normalize(lightPos - (view * objPos).xyz);
        // výpočet difúzní složky ve vrcholech
        intensity = dot(lightDir, normal);
        vertColor = vec3(normal.xyz);

    } else { // per pixel
        normal = normalize(getNormal(position.xy)); // normalizace a výpočet normály
        normal = inverse(transpose(mat3(view * model))) * normal; // transformace normály
        // výpočet vektoru směru světla
        lightDir = normalize(lightPos - (view * objPos).xyz);

        normalIO = normal; // předání normály do FS
    }

    // pohledová a projekční transformace
    gl_Position = proj * view * objPos;
}
