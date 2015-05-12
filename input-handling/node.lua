gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

node.alias "input-example"

local json = require "json"

local function clamp(val, min, max)
    return math.min(max, math.max(min, val))
end

local Mouse = (function()
    local pointer = resource.load_image "pointer.png"
    local x = 0
    local y = 0

    local function draw()
        pointer:draw(x, y, x+32, y+32)
    end

    local function handle_event(ev)
        pp(ev)
        if ev.code == "REL_X" then
            x = clamp(x + ev.value, 0, WIDTH)
        elseif ev.code == "REL_Y" then
            y = clamp(y + ev.value, 0, HEIGHT)
        end
    end

    util.data_mapper{
        ["event"] = function(data)
            handle_event(json.decode(data))
        end
    }

    return {
        draw = draw;
    }
end)()

function node.render()
    Mouse.draw()
end
