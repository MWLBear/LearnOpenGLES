
attribute vec4 position;
attribute vec4 color;

varying vec4 colorVarying;

void main(void) {
    colorVarying = color;
    gl_Position = position;
}



vec4 myVec4 = vec4(1.0);

vec3 myVec3 = vec3(0.0,1.0,2.0);
vec3 temp = myVec3.xyz;
