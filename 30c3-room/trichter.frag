uniform sampler2D Texture;
uniform sampler2D Grid;
uniform sampler2D Overlay;
varying vec2 TexCoord;
uniform float time;

const float segments = 9.0;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main() {
    vec2 pos = TexCoord;

    vec2 coord = texture2D(Texture, pos).st;
    coord.x = mod(coord.x + time, 1.0);
    coord.y = coord.y + 0.0175;
    coord += rand(pos) * 0.008;
    vec3 col = texture2D(Overlay, coord).rgb;

    float foo = floor(coord.y * segments);
    col *= (foo / segments) * 0.6 + 0.4;

    if (pos.y > 0.82) {
        vec3 bar = texture2D(Overlay, pos).rgb;
        col = col * 0.3 + bar * 0.4; //mix(col, bar, 0.3) * 0.8;
    }

    vec4 grid = texture2D(Grid, pos);
    gl_FragColor = vec4(col, 1.0) + grid * 0.09;
}
