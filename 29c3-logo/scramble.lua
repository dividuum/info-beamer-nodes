local sys = require "sys"
local math = require "math"
local table = require "table"
local base = _G

module("scramble")

function scramble(text)
    local all_breaks = '/.-{}()[]<>|,;!?'
    local breaks = {}
    for idx = 1, #all_breaks do
        breaks[all_breaks:sub(idx, idx)]=true
    end
    -- print(#breaks)
    local mode = "up"
    local interval = 0.2
    local swap_end
    local next_action = sys.now() + interval
    local stack = {}

    local function is_break(text, pos)
        local char = text:sub(pos, pos)
        local is_break = breaks[char]
        -- print(char, is_break)
        return is_break, char
    end
    local function random_break()
        local pos = math.random(1, #all_breaks)
        return all_breaks:sub(pos, pos)
    end
    local function replace2(text, pos, c1, c2)
        return text:sub(1, pos-1) .. c1 .. c2 .. text:sub(pos+2)
    end
    local function replace(text, pos, c)
        return text:sub(1, pos-1) .. c  .. text:sub(pos+1)
    end

    local function get()
        local now = sys.now()
        if now > next_action then
            -- print(mode)
            if mode == "up" then
                local pos, is_1_break, is_2_break, char_1, char_2
                repeat
                    pos = math.random(1, #text-1)
                    is_1_break, char_1 = is_break(text, pos)
                    is_2_break, char_2 = is_break(text, pos+1)
                until is_1_break ~= is_2_break
                -- print(pos, is_1_break, is_2_break)

                if is_1_break then
                    table.insert(stack, {pos, random_break(), char_2})
                    text = replace2(text, pos, char_2, random_break())
                else
                    table.insert(stack, {pos, char_1, random_break()})
                    text = replace2(text, pos, random_break(), char_1)
                end
                interval = interval - 0.01
                if interval < 0.02 then
                    mode = "down"
                end
            elseif mode == "down" then
                local pos, char1, char2 = base.unpack(table.remove(stack, #stack))
                text = replace2(text, pos, char1, char2)
                interval = interval + 0.01
                if #stack == 0 then
                    mode = "swap"
                    swap_end = now + 15
                    interval = 2
                end
            elseif mode == "swap" then
                local pos, is_break_char, _
                repeat
                    pos = math.random(1, #text-1)
                    is_break_char, _ = is_break(text, pos)
                until is_break_char
                text = replace(text, pos, random_break())
                if now > swap_end then
                    interval = 0.2
                    mode = "up"
                end
            end
            next_action = now + interval
        end
        return text
    end
    return get
end


