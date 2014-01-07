uniform sampler2D Texture;
varying vec2 TexCoord;
uniform float percent;

void main() {
    vec2 pos = TexCoord;
    float angle = atan(pos.x - 0.5, pos.y - 0.5);
    float dist = distance(pos, vec2(0.5, 0.5));
    if (dist >= 0.5) {
        gl_FragColor = vec4(0.0);
    } else if (angle < percent) {
        gl_FragColor = vec4(1.0);
    } else {
        gl_FragColor = vec4(0.5);
    }
}
