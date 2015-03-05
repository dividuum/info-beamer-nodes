gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

-- http://ansimuz.com/site/archives/807
-- http://redd.it/2v9z27
local res = util.auto_loader()

local layers = resource.create_shader[[
    uniform sampler2D Texture;
    uniform sampler2D l1;
    uniform sampler2D l2;
    uniform sampler2D l3;
    uniform float offset;
    varying vec2 TexCoord;
    vec4 blend(vec4 s, vec4 d) {
        return vec4(s.a*s.rgb + (1.0-s.a)*d.rgb, 1.0);
    }
    void main() {
        vec2 tc = TexCoord;
        tc.x = mod(tc.x + offset, 1.0);
        vec4 col = texture2D(Texture, tc);
        tc.x = mod(tc.x + offset, 1.0);
        col = blend(texture2D(l1, tc), col);
        tc.x = mod(tc.x + offset, 1.0);
        col = blend(texture2D(l2, tc), col);
        tc.x = mod(tc.x + offset, 1.0);
        col = blend(texture2D(l3, tc), col);
        gl_FragColor = col;
    }
]]

function node.render()
    layers:use{
        offset = sys.now()*0.2;
        l1 = res.lights;
        l2 = res.middle;
        l3 = res.front;
    }
    res.back:draw(0, 0, WIDTH, HEIGHT)
end
