#version 150
in vec2 inPosition; // input from the vertex buffer
uniform mat4 model; // modelová matice
uniform mat4 view; // pohledová matice
uniform mat4 proj; // projekční matice
uniform vec3 lightPos; // pozice světla
uniform float time; // pro pohyb tělesa
uniform int objectType; // typ objektu
uniform int lightModelType;
out vec2 posIO;
out vec4 objPos; // výsledná pozice pro FS
out vec3 normalIO; // normála pro FS
out vec3 lightDir; // směr světla pro FS
out vec3 viewDir; // pohledový vektor pro FS

// získání z hodnoty - pro rovinnou podložku a první těleso v kartézských souřadnicích
float getFValue(vec2 vec){
    if (objectType==0) {
        return 0;
    } else {
        return -(vec.x*vec.x*5+vec.y*vec.y*5);
    }
    /*} else {
        return sin(time + vec.y * 3.14 *2);
    }*/
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
    float az = vec.x * 2 * 3.14;
    float ze = vec.y * 3.14;
    float r = 3+cos(4*az);

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

// druhý objekt v cylindrických souřadnicích
vec3 getSpiral(vec2 vec) {
    float az = vec.y * 2 * 3.14; //s - theta
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

    // rozdělení objektů dle vytvoření - výpočet z || xyz
    if(objectType < 2) {
        // výpočet z hodnoty
        float z = getFValue(position.xy);
        objPos = vec4(position.x, position.y, z, 1.0);
    } else if(objectType == 2) {
        // výpočet xyz hodnot
        objPos = vec4(getSphere(position), 1.0);
    } else if(objectType == 3) {
        objPos = vec4(getCone(position), 1.0);
    } else if(objectType == 4) {
        objPos = vec4(getElephantHead(position), 1.0);
    } else if(objectType == 5){
        objPos = vec4(getMyBattleStation(position), 1.0);
    } else if(objectType == 6){
        objPos = vec4(getSombrero(inPosition), 1.0);
    } else {
        objPos = vec4(getSpiral(position), 1.0);
    }

    objPos = model * objPos; // modelová transformace

    // výpočet vektoru směru světla
    lightDir = lightPos - (view * objPos).xyz;
    //texCoord = inPosition;

    // výpočet vektoru pohledu (pouze v případě phonga)
    if( lightModelType == 0)
        viewDir = -(view* objPos).xyz;


    vec3 normal = mat3(view) * normalize(getNormal(position.xy)); // normalizace normály
    normal =  transpose(inverse(mat3(view*model)))*normal; // transformace normály
    normalIO = normal; // předání normály do FS

    // pohledová a projekční transformace
    gl_Position = proj*view*objPos;
}
