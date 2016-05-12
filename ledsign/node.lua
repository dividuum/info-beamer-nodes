gl.setup(1920, 1080)

local json = require "json"
local deque = require "deque"

local ROWS = 8
local COLS = 18

local content
util.file_watch("content.json", function(raw)
    content = json.decode(raw)
end)

local function lines_from_string(str)
    local function rpad(str, size, fill)
        if #str < size then
            str = str .. fill:rep(size - #str)
        end
        return str
    end

    local lines = {}
    for idx = 1, ROWS do
        local offset = 1 + (idx-1) * COLS
        lines[idx] = rpad(str:sub(offset, offset+COLS-1), COLS, ' ')
    end
    return lines
end

local function Sign()
    local font = resource.load_font "ballplay.ttf"
    local lines

    local function draw()
        gl.scale(1.007, 1.3)
        for i = 1, ROWS do
            local line = lines[i]
            local y = 15 + (i-1)*104
            font:write(-2, y, line, 106, 1, 0.75, 0, 1)
        end
    end

    local function clear()
        lines = {}
        local row = string.rep(" ", COLS)
        for i = 1, ROWS do
            lines[i] = row
        end
    end

    local function set(new_lines)
        lines = new_lines
    end

    clear()

    return {
        draw = draw;
        clear = clear;
        set = set;
    }
end

local function Player(sign)
    local queue = deque:new()
    local can_interrupt = true
    local next_switch = sys.now()

    local function refill()
        for idx = 1, #content do
            local item = content[idx]
            queue:push_right{
                lines = item.lines;
                duration = item.duration;
                interruptable = true;
            }
        end
    end

    local function tick()
        local now = sys.now()
        if now >= next_switch then
            if queue:is_empty() then
                refill()
            end

            local item = queue:pop_left()
            next_switch = now + item.duration
            can_interrupt = item.interruptable
            sign.set(item.lines)
        end
    end

    local function add(lines, duration)
        if can_interrupt then
            sign.set(lines)
            next_switch = sys.now() + duration
            can_interrupt = false
            -- reset queue, so additional 'add'ed
            -- signs can be inserted in order without
            -- being interrupted by automated content
            -- already in the queue.
            queue = deque:new()
        else
            queue:push_right{
                lines = lines;
                duration = duration;
                interruptable = false;
            }
        end
    end

    return {
        tick = tick;
        add = add;
    }
end

local sign = Sign()
local player = Player(sign)

node.alias "sign"

util.data_mapper{
    ["add/([0-9]+)"] = function(duration, text)
        player.add(lines_from_string(text:upper()), tonumber(duration))
    end
}

function node.render()
    player.tick()
    sign.draw()
end
