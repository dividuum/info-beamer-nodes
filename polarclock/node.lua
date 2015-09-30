-- inspired by http://raphaeljs.com/polar-clock.html
gl.setup(1920, 1080)

local fill = resource.create_shader[[
    uniform float r, g, b;
    varying vec2 TexCoord;
    void main() {
        gl_FragColor = vec4(r, g, b, TexCoord.x);
    }
]]

local circle = resource.create_shader[[
    varying vec2 TexCoord;
    uniform float r, g, b;
    uniform float width;
    uniform float progress;
    void main() {
        float e = 0.003;
        float angle = atan(TexCoord.x - 0.5, TexCoord.y - 0.5);
        float dist = distance(vec2(0.5, 0.5), TexCoord.xy);
        float inner = (1.0 - width) / 2.0;
        float alpha = (smoothstep(0.5, 0.5-e, dist) - smoothstep(inner+e, inner, dist)) * smoothstep(progress-0.01, progress, angle);
        gl_FragColor = vec4(r, g, b, alpha);
    }
]]

local dummy = resource.create_colored_texture(1,0,0,1)
local font = resource.load_font "silkscreen.ttf"

local function to_angle(value, min, max)
    return math.pi - (value - min) / (max-min) * math.pi * 2
end

-- from https://github.com/stackgl/glsl-easings/blob/master/elastic-out.glsl
local function elastic(t)
    return math.sin(-13.0 * (t + 1.0) * math.pi/2) * math.pow(2.0, -10.0 * t) + 1.0
end

-- from https://github.com/wiremod/wire/blob/master/lua/entities/gmod_wire_expression2/core/color.lua
local function hsl2rgb(h, s, l)
    local function hue2rgb(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < 1/6 then return p + (q - p) * 6 * t end
        if t < 1/2 then return q end
        if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
        return p
    end
    local r, g, b = l, l, l
    if s ~= 0 then
        local q = l + s - l * s
        if l < 0.5 then q = l * (1 + s) end
        local p = 2 * l - q
        r = hue2rgb(p, q, h + 1/3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1/3)
    end
    return r, g, b
end

local function arc(cx, cy, radius, width, min, max, hue, sat)
    local target_val = 0
    local s = sys.now()
    return function(val)
        if val ~= target_val then
            s = sys.now()
            target_val = val
        end
        local v = elastic(sys.now() - s) + target_val - 1
        local r, g, b = hsl2rgb(hue + val/400, sat, 0.5)
        circle:use{
            r = r, g = g, b = b,
            width = 1.0 / radius * width,
            progress = to_angle(v, min, max),
        }
        dummy:draw(cx-radius, cy-radius, cx+radius, cy+radius)
        circle:deactivate()
        fill:use{
            r = r, g = g, b = b,
        }
        dummy:draw(cx-600, cy-radius+1, cx, cy-radius+width-1)
        local w = font:width(target_val, width)
        font:write(cx-300-w, cy-radius, target_val, width-2, r,g,b,.9)
    end
end

local arcs = {
    --                                              hue  sat
    month  = arc(WIDTH/2, HEIGHT/2, 120, 20, 0, 12, 0.3, 0.2);
    day    = arc(WIDTH/2, HEIGHT/2, 150, 20, 0, 31, 0.4, 0.2);

    hour   = arc(WIDTH/2, HEIGHT/2, 300, 30, 0, 24, 0.9, 0.8);
    minute = arc(WIDTH/2, HEIGHT/2, 260, 30, 0, 60, 0.6, 0.8);
    second = arc(WIDTH/2, HEIGHT/2, 220, 30, 0, 60, 0.3, 0.9);
}

function node.render()
    local t = os.date("*t")
    arcs.month(t.month)
    arcs.day(t.day)
    arcs.second(t.sec)
    arcs.minute(t.min)
    arcs.hour(t.hour)
end
