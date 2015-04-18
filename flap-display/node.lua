gl.setup(1920, 1080)

if not sys.provides "subimage-draw" then
    error "needs at least info-beamer 0.9 pre6"
end

local Display = function(display_cols, display_rows)
    local t = resource.load_image "letters.png"
    local mapping = ' ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜ0123456789@#-.,:?!()'

    local function make_mapping(cols, rows, tw, th)
        local chars = {}
        for i = 0, #mapping * 5 - 1 do
            local cw = tw/cols
            local ch = th/rows
            local x =           (i % cols) * cw
            local y = math.floor(i / cols) * ch
            chars[#chars+1] = function(x1, y1, x2, y2)
                t:draw(x1, y1, x2, y2, 1.0, x/tw, y/th, (x+cw)/tw, (y+ch)/th)
            end
        end
        return chars
    end

    local charmap = make_mapping(20, 13, 2000, 1950)

    local row = function(rowsize)
        local function mkzeros(n)
            local out = {}
            for i = 1, n do 
                out[#out+1] = 0
            end
            return out
        end

        local current = mkzeros(rowsize)
        local target  = mkzeros(rowsize)
        local function set(value)

            assert(#value <= rowsize)
            value = value .. string.rep(" ", rowsize-#value)
            for i = 1, rowsize do
                local char = string.sub(value,i,i):upper()
                local pos = string.find(mapping, char, 1, true)
                if not pos then
                    pos = 1 -- character not found
                end
                target[i] = (pos-1) * 5
            end
        end
        set("")

        local function tick()
            for i = 1, rowsize do
                if current[i] ~= target[i] then
                    current[i] = current[i] + 1
                    if current[i] >= #mapping * 5 then
                        current[i] = 0
                    end
                end
            end
        end

        local function draw(y, charh)
            local charw = WIDTH / rowsize
            local margin = 2
            for i = 1, rowsize do
                charmap[current[i]+1]((i-1)*charw+margin, y+margin, i*charw-margin, y+charh-margin)
            end
        end

        return {
            set = set;
            tick = tick;
            draw = draw;
        }
    end

    local rows = {}
    for i = 1, display_rows do
        rows[#rows+1] = row(display_cols)
    end

    local current = 1
    local function append(line)
        line = line:sub(1, display_cols)
        rows[current].set(line)
        current = current + 1
        if current > #rows then
            current = 1
        end
    end

    local function go_up()
        current = 1
    end

    local function clear()
        for i = 1, display_rows do
            rows[i].set("")
        end
        go_up()
    end

    local function draw()
        local charh = HEIGHT / display_rows
        for i = 1, display_rows do
            rows[i].tick()
            rows[i].draw((i-1)*charh, charh)
        end
    end

    append "tcp connect to port 4444"
    append "type ,display,"
    append "write text :-)"

    return {
        append = append;
        clear = clear;
        go_up = go_up;
        draw = draw;
    }
end

local Clients = function(display)
    node.alias "display"

    local clients = {}

    local function readln()
        return coroutine.yield()
    end

    local function prompt(send)
        send "connected"
        while true do
            local line = readln()
            -- you might build a better protocol here
            if line == "##clear##" then
                display.clear()
            elseif line == "##go_up##" then
                display.go_up()
            else
                display.append(line)
            end
        end
    end

    node.event("connect", function(client, path)
        local handler = coroutine.wrap(prompt, readln)
        clients[client] = handler
        handler(function(...)
            node.client_write(client, ...)
        end)
    end)

    node.event("input", function(line, client)
        clients[client](line)
    end)

    node.event("disconnect", function(client)
        clients[client] = nil
    end)
end

local display = Display(25, 10)
local clients = Clients(display)
    
function node.render()
    display.draw()
end
