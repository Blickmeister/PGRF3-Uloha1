#version 150
in vec2 inPosition; // input from the vertex buffer
uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;
uniform int mode;
uniform vec3 lightPos;
uniform float time;
out vec2 posIO;
out vec4 objPos;
out vec3 normalIO;
out vec3 lightDir;
out vec3 viewDir;

// získání z hodnoty
float getFValue(vec2 xy){
    if (mode==0) {
        return 0;
    } else {
        return -(xy.x*xy.x*5+xy.y*xy.y*5);
    }
    /*} else {
        return sin(time + xy.y * 3.14 *2);
    }*/
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

    // rozdělení objektů dle vytvoření - výpočet z||xyz
    if(mode < 2) {
        float z = getFValue(position.xy);
        objPos = model*vec4(position.x, position.y, z, 1.0);
    } else {
        objPos = model*vec4(getSphere(position), 1.0);
    }

    lightDir = lightPos - (view * objPos).xyz;
    //texCoord = inPosition;
    viewDir = -(view* objPos).xyz;

    vec3 normal = mat3(view) * normalize(getNormal(position.xy));
    normal =  transpose(inverse(mat3(view*model)))*normal;
    normalIO = normal;

    gl_Position = proj*view*objPos;
}
