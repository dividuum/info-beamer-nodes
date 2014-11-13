gl.setup(1024, 768) -- change this to the native resolution

local json = require "json"

-- Helper function to create shader based transitions
local function make_blender(blend_src)
    local function create_shader(main_src)
        local src = [[
            uniform sampler2D Texture;
            varying vec2 TexCoord;
            uniform vec4 Color;
            uniform float progress;

            float blend(float x) {
                ]] .. blend_src .. [[
            }
            void main() {
                ]] .. main_src .. [[
            }
        ]]
        return resource.create_shader(src)
    end
    local s1 = create_shader[[
        gl_FragColor = texture2D(Texture, TexCoord) * vec4(1.0 - blend(progress));
    ]]
    local s2 = create_shader[[
        gl_FragColor = texture2D(Texture, TexCoord) * vec4(blend(progress));
    ]]
    return function(c, n, progress, x1, y1, x2, y2)
        s1:use{ progress = progress }
        util.draw_correct(c, x1, y1, x2, y2)
        s2:use{ progress = progress }
        util.draw_correct(n, x1, y1, x2, y2)
        s2:deactivate()
    end
end

----------------------------------------------------------------
-- Available Transitions
----------------------------------------------------------------
local transitions = {
    crossfade = function(c, n, progress, x1, y1, x2, y2)
        util.draw_correct(c, x1, y1, x2, y2, 1.0 - progress)
        util.draw_correct(n, x1, y1, x2, y2, progress)
    end;

    move = function(c, n, progress, x1, y1, x2, y2)
        local xx = WIDTH * progress
        util.draw_correct(c, x1 + xx, y1, x2 + xx, y2, 1.0 - progress)
        util.draw_correct(n, x1 - WIDTH + xx, y1, x2 - WIDTH + xx, y2, progress)
    end;

    move_shrink = function(c, n, progress, x1, y1, x2, y2)
        local xx = WIDTH * progress
        util.draw_correct(c, x1 + xx, y1, x2, y2, 1.0 - progress)
        util.draw_correct(n, x1 - WIDTH + xx, y1, x2 - WIDTH + xx, y2, progress)
    end;

    flip = function(c, n, progress, x1, y1, x2, y2)
        local xx = WIDTH * progress
        gl.pushMatrix()
            gl.translate(WIDTH/2, HEIGHT/2)
            gl.rotate(progress * 90, 0, 1, 0)
            gl.translate(-WIDTH/2, -HEIGHT/2)
            util.draw_correct(c, x1 + xx, y1, x2, y2, 1.0 - progress)
        gl.popMatrix()

        gl.pushMatrix()
            gl.translate(WIDTH/2, HEIGHT/2)
            gl.rotate(90 - progress * 90, 0, 1, 0)
            gl.translate(-WIDTH/2, -HEIGHT/2)
            util.draw_correct(n, x1 - WIDTH + xx, y1, x2 - WIDTH + xx, y2, progress)
        gl.popMatrix()
    end;

    blend1 = make_blender[[
        x = 1.0 - clamp(TexCoord.x - 1.0 + x * 3.0, 0.0, 1.0);
        return 2.0 * x * x * x - 3.0 * x * x + 1.0;
    ]],

    blend2 = make_blender[[
        x = 1.0 - clamp(TexCoord.y - 1.0 + x * 3.0, 0.0, 1.0);
        return 2.0 * x * x * x - 3.0 * x * x + 1.0;
    ]],

    blend3 = make_blender[[
        vec2 center = vec2(0.5, 0.5);
        vec2 c = TexCoord - center;
        float angle = atan(c.x, c.y) / 3.1415926536;
        float dist = length(c);
        x = abs(mod(angle + dist * 5.0 + x, 2.0) - 1.0) + dist - 2.0 + x * 4.0;
        x = 1.0 - clamp(x, 0.0, 1.0);
        return 2.0 * x * x * x - 3.0 * x * x + 1.0;
    ]],

    blend4 = make_blender[[
        float y = sin( (TexCoord.x - 0.5) * x * 4.0) * sin( (TexCoord.y - 0.5) * x * 4.0);
        return clamp(y - 1.0 + x * 4.0, 0.0, 1.0);  
    ]],

    blend5 = make_blender[[
        return clamp(distance(TexCoord, vec2(0.5, 0.5)) - 1.0 + x * 3.0, 0.0, 1.0);
    ]],

    blend6 = make_blender[[
        return 1.0 - (2.0 * x * x * x - 3.0 * x * x + 1.0);
    ]],
}


----------------------------------------------------------------
-- Remote controllable Slideshow
----------------------------------------------------------------
local state = "idle"
local switch
local current_image = resource.create_colored_texture(0, 0, 0, 1)

-- 1) tcp connection to info-beamer:4444
-- 2) send "slideshow"
-- 3) send json data
--
-- alternatively:
-- 1) send slideshow:<json> to info-beamer:4444 on udp
node.alias("slideshow")

-- This function gets called when a complete line is sent using
-- the tcp connection. the line is expected to be json formatted:
--
-- {"filename": "1.jpg", "transition": "crossfade", "duration": 3}
-- {"filename": "2.jpg", "transition": "flip", "duration": 1}

function decode_command(line)
    local cmd = json.decode(line)
    switch = {
        transition = transitions[cmd.transition];
        duration = cmd.duration or 1;
        image = resource.load_image(cmd.filename);
        start = nil; -- gets filled in start_switch state
    }
    state = "start_switch"
end

node.event("input", decode_command) -- listen to TCP
node.event("data", decode_command)  -- listen to UDP

function node.render()
    if state == "idle" then
        -- default state: draw current image
        util.draw_correct(current_image, 0, 0, WIDTH, HEIGHT)
    elseif state == "start_switch" then
        -- begin switch to next image.
        util.draw_correct(current_image, 0, 0, WIDTH, HEIGHT)
        switch.start = sys.now()
        state = "switch"
    elseif state == "switch" then
        -- draw transition and switch to end_switch state
        -- once the switch is completed.
        local progress = (sys.now() - switch.start) / switch.duration
        switch.transition(current_image, switch.image, math.min(progress, 1.0), 0, 0, WIDTH, HEIGHT)
        if progress > 1 then
            state = "end_switch"
        end
    elseif state == "end_switch" then
        -- ends the switch. current image is now the
        -- switched to image. hop back to idle state
        current_image = switch.image
        switch = nil
        util.draw_correct(current_image, 0, 0, WIDTH, HEIGHT)
        state = "idle"
    end
end
