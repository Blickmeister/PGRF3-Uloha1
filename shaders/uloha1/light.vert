#version 150
in vec2 inPosition; // input from the vertex buffer
uniform mat4 model; // modelová matice pro světlo
uniform mat4 view; // pohledová matice pro světlo
uniform mat4 proj; // projekční matice pro světlo
uniform int objectType; // typ objektu pro vykreslení
uniform int lightModelType; // typ světelného modelu
uniform float time; // pro pohyb tělesa
out vec4 pos; // výsledná pozice pro FS

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

void main() {
	vec2 position = inPosition-0.5;

	// rozdělení objektů podle zvoleného modelu osvětlení
	if(lightModelType == 0) { // Blinn-Phong

		// rozdělení objektů dle vytvoření - výpočet z || xyz
		if (objectType < 2) {
			// výpočet z hodnoty
			float z = getFValue(position.xy); // první objekt v kart souřadnicích a rovinná ploška
			pos = vec4(position.x, position.y, z, 1.0);
		} else if (objectType == 2) {
			// výpočet xyz hodnot
			pos = vec4(getCone(position), 1.0); // přesýpací hodiny
		} else if (objectType == 3) {
			pos = vec4(getElephantHead(position), 1.0); // sloní hlava
		} else if (objectType == 4) {
			pos = vec4(getMyBattleStation(position), 1.0); // moje bitevní stanice
		} else if (objectType == 5){
			pos = vec4(getSombrero(inPosition), 1.0); // sombrero
		} else if (objectType == 6){
			pos = vec4(getSpiral(position), 1.0); // spirála
		}
	} else { // Per vertex/Per pixel
		if (objectType == 7) {
			pos = vec4(getBean(position), 1.0);// 1. fazolka
		} else if (objectType == 8) {
			pos = vec4(getBean(position), 1.0);// 2. fazolka
		}
	}
	// MVP transformace
	gl_Position = proj*view*model*pos;
	pos = proj*view*model*pos;
}
