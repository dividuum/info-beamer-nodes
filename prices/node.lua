gl.setup(1920, 1200)

util.resource_loader{
    "font.ttf";
    "background.png";
    "entropia.png";
}

local Absatz = "absatz"

local preise = {
    {"Wasser",    "1"},
    {"A-Schorle", "1.5"},
    {"Mate",      "1.5"},
    {"Cola",      "1.5"},
    Absatz,
    {"Radler",    "2"},
    {"Bier",      "2"},
    Absatz,
    {"Pfand",     "1"},
}

function Preisliste(preise, x, y, spacing, size)
    local row
    local col
    local next_kaputt

    function select_next()
        repeat
            row = math.random(#preise)
        until preise[row] ~= Absatz
        local title, price = unpack(preise[row])
        col = math.random(#title - 1)
        next_kaputt = sys.now() + math.random() * 60 + 30
    end

    select_next()

    function draw()
        local yy = y
        for n, item in pairs(preise) do
            if item == Absatz then
                yy = yy + size
            else
                local title, price = unpack(item)
                if sys.now() > next_kaputt - 3 and n == row then
                    local a = title:sub(1, col-1)
                    local b = title:sub(col, col)
                    local c = title:sub(col+1, col+1)
                    local d = title:sub(col+2)
                    title = a .. c .. b .. d
                    font:write(x, yy, title, size, .1,.7,.1,1)
                elseif sys.now() > next_kaputt then
                    select_next()
                    font:write(x, yy, title, size, .1,.7,.1,1)
                else
                    font:write(x, yy, title, size, .1,.7,.1,1)
                end
                font:write(x + spacing, yy, price, size, .1,.7,.1,1)
                yy = yy + size
            end
        end
    end
    return {
        draw = draw;
    }
end

local logo_shader = resource.create_shader([[
    uniform sampler2D Texture;
    varying vec2 TexCoord;
    uniform vec4 Color;
    void main() {
        vec4 texel = texture2D(Texture, TexCoord.st);
        // gl_FragColor = Color * texel;
        gl_FragColor = vec4(1.0, 1.0, 1.0, texel.a);
    }
]])

local distort_shader = resource.create_shader([[
    uniform sampler2D Texture;
    varying vec2 TexCoord;
    uniform vec4 Color;
    uniform float effect;
    void main() {
        vec2 uv = TexCoord.st;
        vec4 col;
        col.r = texture2D(Texture,vec2(uv.x+effect+sin(uv.y*20.0*effect)*0.02,uv.y)).r;
        col.g = texture2D(Texture,vec2(uv.x+effect+sin(uv.y*30.0*effect)*0.02,uv.y)).g;
        col.b = texture2D(Texture,vec2(uv.x-effect+sin(uv.y*40.0*effect)*0.02,uv.y)).b;
        col.a = texture2D(Texture,vec2(uv.x,uv.y)).a;
        gl_FragColor = Color * col;
    }
]])
 
 
local crt_shader = resource.create_shader([[
    uniform float time;
    uniform sampler2D Texture;
    varying vec2 TexCoord;
    uniform vec4 Color;

    void main(void)
    {
        vec2 q = TexCoord;
        vec2 uv = 0.5 + (q-0.5)*(0.98 + 0.0002*sin(0.2*time));

        vec3 oricol = texture2D(Texture,vec2(q.x,1.0-q.y)).xyz;
        vec3 col;

        float fnord = sin(time*1.0) * 0.001;
        col.r = texture2D(Texture,vec2(uv.x+fnord,uv.y)).x;
        col.g = texture2D(Texture,vec2(uv.x+0.000,uv.y)).y;
        col.b = texture2D(Texture,vec2(uv.x-fnord,uv.y)).z;

        col = clamp(col*0.5+0.5*col*col*1.2,0.0,1.0);
        col *= 0.5 + 0.5*16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y);
        col *= vec3(0.8,1.0,0.7);
        col *= 0.9+0.1*sin(5.0*time+uv.y*1000.0);
        col *= 0.97+0.03*sin(3.0*time);

        float comp = smoothstep( 0.2, 0.5, sin(time) );

        gl_FragColor = vec4(col,1.0);
    }
]])

pictures = util.generator(function()
    local out = {}
    for name, _ in pairs(CONTENTS) do
        if name:match(".*jpg") then
            out[#out + 1] = name
        end
    end
    return out
end)
node.event("content_remove", function(...)
    pictures:remove(...)
end)

function PicRotation(x1, y1, x2, y2, time)
    local image
    function next_image()
        image = resource.load_image(pictures.next())
        switch = sys.now() + time
    end

    next_image()

    local switch_time = 0.2

    function draw()
        local remaining = switch - sys.now()
        local abs = 10
        if remaining < switch_time then 
            abs = switch_time - remaining
        end
        if remaining > time - switch_time then
            abs = remaining - time + switch_time
        end
        if abs < switch_time then
            abs = abs / switch_time
            distort_shader:use{
                effect = abs * 10 * math.sin(sys.now()) * 3;
            }
        end
            util.draw_correct(image, x1, y1, x2, y2)
        distort_shader:deactivate()
        if sys.now() > switch then
            next_image()
        end
    end

    return {
        draw = draw;
    }
end


local source = (function()
    local lines = {}
    util.file_watch("info.txt", function(content)
        lines = {}
        for line in content:gmatch("[^\n]+") do
            lines[#lines+1] = line
        end
    end)
    return util.generator(function ()
        return lines
    end)
end)()


function Crapterm(source, x, y, size)
    local errors = "qwertyuiopasdfghjklzxcvbnm"
    local line
    local steps
    local step
    local next_step
    local speed = 0.3
    local cursor_base = sys.now()

    function next_line()
        line = source:next()
        step = 1
        steps = {}

        -- leerer anfang
        steps[#steps+1] = {
            "",
            1.0
        }

        -- hintippen
        for size = 1, #line do
            steps[#steps+1] = {
                line:sub(1, size), 
                0.1 + math.random() * speed
            }
        end

        -- tippfehler einfuegen
        local mistakes = math.random(3)
        for _ = 1,mistakes do
            local off = math.random(#steps-1)
            local base_string, delay = unpack(steps[off])
            local err_off = math.random(#errors)
            local err = errors:sub(err_off, err_off)
            table.insert(steps, off+1, {
                base_string .. err, 
                0.1 + math.random() * speed
            })
            table.insert(steps, off+2, {
                base_string, 
                0.1 + math.random() * speed / 2
            })
        end
        -- ergebnis laenger stehen lassen
        steps[#steps-1][2] = 3.0

        -- loeschen
        for size = #line-1, 1, -1 do
            steps[#steps+1] = {
                line:sub(1, size),
                0.1 + math.random() * speed / 5
            }
        end

        -- leeres ende
        steps[#steps+1] = {
            "",
            1.0
        }
        next_step = sys.now() + steps[1][2]
    end
    
    next_line()

    function draw()
        local current, delay = unpack(steps[step])
        current = "> " .. current
        local cursor_x = font:write(x, y, current, size, .1,.7,.1,1)
        cursor_x = cursor_x + 40
        if ((sys.now() - cursor_base)*2) % 2 < 1 then
            font:write(cursor_x, y, "_", size, .1,.7,.1,1)
        end

        if sys.now() > next_step then
            step = step + 1
            if step > #steps then
                next_line()
            end
            next_step = sys.now() + delay
            cursor_base = sys.now()
        end
    end

    return {
        draw = draw;
    }
end

local pic = PicRotation(950, 350, WIDTH-100, HEIGHT-200, 8)
local term = Crapterm(source, 40, 1080, 100)
local preisliste = Preisliste(preise, 40, 50, 680, 105)

local countdown = sys.now() + math.random() * 10

function node.render()
    background:draw(0,0,WIDTH,HEIGHT)
    preisliste:draw()
    term:draw()
    pic:draw()
    logo_shader:use()
        gl.perspective(50,
            WIDTH/2+60, HEIGHT/2+45, -WIDTH/1.38,
            WIDTH/2+60, HEIGHT/2+45, 0
        )
        gl.pushMatrix()
            gl.translate(950, -90)
            gl.rotate(10, 0, 0, 1)
            gl.translate(0, 200)
            -- gl.rotate((sys.now()*100) % 180-90, 1, 0, 0)
            gl.rotate(math.sin(sys.now()/2.0)*15, 1, 0, 0)
            gl.rotate(math.sin(sys.now()/5.0)*8, 0, 1, 0)
            gl.translate(0, -200)
            util.draw_correct(entropia, 0, 0, 1100, 500, 1,0,0,1)
        gl.popMatrix()
        gl.ortho()
    logo_shader:deactivate()
    util.post_effect(crt_shader, {
        time = sys.now(),
    })
    
    -- local remaining = countdown - sys.now()
    -- if remaining < 0 then
    --     countdown = sys.now() + math.random() * 10
    -- elseif remaining < 0.3 then
    --     util.post_effect(distort_shader, {
    --         effect = math.random() * math.sin(sys.now()) * 200
    --     })
    -- end
end
