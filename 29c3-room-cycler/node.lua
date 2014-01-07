gl.setup(1920, 1080)

local interval = 10

util.auto_loader(_G)

local distort_shader = resource.create_shader([[
    uniform sampler2D Texture;
    uniform float effect;
    varying vec2 TexCoord;
    uniform vec4 Color;
    void main() {
        vec2 uv = TexCoord.st;
        vec4 col;
        col.r = texture2D(Texture, vec2(uv.x+sin(uv.y*20.0*effect)*0.2,uv.y)).r;
        col.g = texture2D(Texture, vec2(uv.x+sin(uv.y*25.0*effect)*0.2,uv.y)).g;
        col.b = texture2D(Texture, vec2(uv.x+sin(uv.y*30.0*effect)*0.2,uv.y)).b;
        col.a = texture2D(Texture, vec2(uv.x,uv.y)).a;
        vec4 foo = vec4(1.0,1.0,1.0,effect);
        col.a = 1.0;
        gl_FragColor = Color * col * foo;
    }
]])

function make_switcher(childs, interval)
    local next_switch = 0
    local child
    local function next_child()
        child = childs.next()
        next_switch = sys.now() + interval
    end
    local function draw()
        if sys.now() > next_switch then
            next_child()
        end
        util.draw_correct(resource.render_child(child), 0, 0, WIDTH, HEIGHT)

        local remaining = next_switch - sys.now()
        if remaining < 0.2 or remaining > interval - 0.2 then
            util.post_effect(distort_shader, {
                effect = 5 + remaining * math.sin(sys.now() * 50);
            })
        end
    end
    return {
        draw = draw;
    }
end

local switcher = make_switcher(util.generator(function()
    local cycle = {}
    for child, updated in pairs(CHILDS) do
        table.insert(cycle, child)
    end
    return cycle
end), interval)


function node.render()
    gl.clear(0, 0.02, 0.2, 1)
    switcher.draw()
end
