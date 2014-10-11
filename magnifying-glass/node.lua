gl.setup(1280, 1024)

local image = resource.load_image("image.jpg")

local magifier = resource.create_shader[[
    uniform sampler2D Texture;
    varying vec2 TexCoord;
    uniform vec4 Color;
    uniform float radius;
    void main() {
        vec2 direction = TexCoord.xy - vec2(0.5, 0.5);
        float dist = length(direction);
        if (dist < 0.5 && dist > 0.495) {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 0.7);
        } else if (dist <= 0.495) {
            float norm_dist = dist * 2.0;
            vec2 magified = vec2(0.5, 0.5) + direction * log(4.0 + norm_dist * norm_dist) / 2.5;
            gl_FragColor = vec4(texture2D(Texture, magified).rgb * (1.0 - 0.1 * norm_dist), 1.0) * Color;
        }
    }
]]

function node.render()
    util.draw_correct(image, 0, 0, WIDTH, HEIGHT)

    local radius = 200
    local center_x = WIDTH/2
    local center_y = HEIGHT/2
    local t = sys.now() / 2
    local x = math.floor(center_x + math.cos(t*1.7) * (center_x - radius) - radius)
    local y = math.floor(center_y + math.sin(t*3.3) * (center_y - radius) - radius)
    local snap = resource.create_snapshot(x, y, radius*2, radius*2)

    magifier:use{radius = radius}
    snap:draw(x, y, x+radius*2, y+radius*2)
end
