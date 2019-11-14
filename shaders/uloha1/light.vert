#version 150
in vec2 inPosition; // input from the vertex buffer
uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;
uniform int objectType;
out vec4 pos;

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

void main() {
	vec2 position = inPosition-0.5;
	if(objectType < 2) {
		// výpočet z hodnoty
		float z = getFValue(position.xy);
		pos = vec4(position.x, position.y, z, 1.0);
	} else if(objectType == 2) {
		// výpočet xyz hodnot
		pos = vec4(getCone(position), 1.0);
	} else if(objectType == 3) {
		pos = vec4(getElephantHead(position), 1.0);
	} else if(objectType == 4) {
		pos = vec4(getMyBattleStation(position), 1.0);
	} else if(objectType == 5){
		pos = vec4(getSombrero(inPosition), 1.0);
	} else {
		pos = vec4(getSpiral(position), 1.0);
	}

	gl_Position = proj*view*model*pos;
	//pos = proj*view*model*pos;
}
