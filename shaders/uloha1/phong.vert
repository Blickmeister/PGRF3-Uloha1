#version 150
in vec2 inPosition; // input from the vertex buffer
uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;
uniform int objectType;
uniform vec3 lightPos;
out vec2 posIO;
out vec4 objPos;
out vec3 normal;
out vec3 lightDir;
out vec3 viewDir;

//uniform float x;
//uniform float y;
//uniform float z;

// získání z hodnoty
float getFValue(vec2 xy){
    if (objectType==0)
    return 0;
    return -(xy.x*xy.x*5+xy.y*xy.y*5);
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

// výpočet koule - reprezentace zdroje světla
vec3 getSphere(vec2 vec) {
    float az = vec.x * 3.14*2;
    float ze = vec.y * 3.14;
    float r = 1;

    float x = r*cos(az)*cos(ze);
    float y = r*sin(az)*cos(ze);//2pryc
    float z = r*sin(ze);//0.5pryc

    return vec3(x, y, z);
}

void main() {
    posIO = inPosition;
    vec2 position = inPosition -  0.5;

    // rozdělení objektů dle vytvoření - výpočet z/xyz
    if(objectType < 2) {
        float z = getFValue(position.xy);
        objPos = model*vec4(position.x, position.y, z, 1.0);
    } else {
        objPos = model*vec4(getSphere(position), 1.0);
    }

    //vec3 light = vec3(x,y,z);

    lightDir = lightPos - (view * objPos).xyz;
    //texCoord = inPosition;
    viewDir = -(view* objPos).xyz;

    normal = mat3(view)* getNormal(position.xy);

    gl_Position = proj*view*objPos;
}
// ---------------------------------------------- ke kopceni perV/perP
// výpočet fazolky (sférické souřadnice) pro demonstraci rozdílu mezi per vertex a per pixel
/*vec3 getBean(vec2 vec) {
    float az = vec.x * 3.14 *2;
    float ze = vec.y * 3.14;
    float r = 1;

    float x = r*cos(az)*cos(ze);
    float y = 2 * r*sin(az)*cos(ze);
    float z = 0.5 * r*sin(ze);

    return vec3(x, y, z);
}

if(objectType == 8) { // 1. fazolka
    objPos = vec4(getBean(position), 1.0);
} else if(objectType == 9) { // 2. fazolka
    objPos = vec4(getBean(position), 1.0);
} else if(objectType == 10) { // světlo
    objPos = vec4(getSphere(position), 1.0);
}

vec4 posMV = view * model * objPos;
vec3 normal;

if(lightModelType == 1) { // per vertex
    normal = normalize(getNormal(position.xy)); // normalizace a výpočet normály
    normal = inverse(transpose(mat3(view * model))) * normal; // transformace normály
    // výpočet vektoru směru světla
    lightDir = normalize(lightPos - posMV.xyz);
    // výpočet difúzní složky ve vrcholech
    intensity = dot(lightDir, normal);
    //vertColor = vec3(normal.xyz);
} else { // per pixel
    normal = normalize(getNormal(position.xy)); // normalizace a výpočet normály
    normal = inverse(transpose(mat3(view * model))) * normal; // transformace normály
    // výpočet vektoru směru světla
    lightDir = normalize(lightPos - posMV.xyz);

    normalIO = normal; // předání normály do FS
}*/
