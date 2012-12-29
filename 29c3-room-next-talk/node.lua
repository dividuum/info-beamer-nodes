gl.setup(1920, 1080)

local json = require"json"

util.auto_loader(_G)

util.file_watch("schedule.json", function(content)
    talks = json.decode(content)
end)
util.file_watch("saal", function(content)
    saal = content:match'^%s*(.*%S)' or ''
end)
pp(saal)

function cluttered()
    local all_breaks = '/.-{}()[]<>|,;!? '
    local breaks = {}
    for idx = 1, #all_breaks do
        breaks[all_breaks:sub(idx, idx)]=true
    end

    local next_change
    local start
    local duration
    local start_text
    local end_text
    local text

    local function go(s, e, d)
        start_text = s
        end_text = e
        start = sys.now()
        duration = d
        text = start_text
    end

    local function speed(t)
        return math.pow((math.sin(t / duration * math.pi)+1) / 2, 2)
    end

    local function next_time()
        next_change = sys.now() + speed()
    end

    local function get()
        if not start then
            return ""
        end
        local t = sys.now() - start
        if t > duration then
            return end_text
        end
        local s = speed(t)
        local spread = math.max(math.min(1.0 / duration * t, 1.0), 0)
        local len = #text
        local pos = 0
        text = string.gsub(text, "(.)", function (x)
            pos = pos + 1
            local r = math.random()
            if t < duration / 2 then
                if r < s / #start_text * spread  then
                    local p = math.random(1, #all_breaks)
                    return all_breaks:sub(p,p)
                elseif r < s / #start_text then
                    local p = math.random(1, #start_text)
                    return start_text:sub(pos,pos)
                else
                    return
                end
            else
                if r < s / #end_text * (1 - spread) then
                    local p = math.random(1, #all_breaks)
                    return all_breaks:sub(p,p)
                elseif r < s / #end_text then
                    return end_text:sub(pos, pos)
                else
                    return
                end
            end
        end)
        return text
    end
    return {
        go = go;
        get = get;
    }
end

function wrap(str, limit, indent, indent1)
    limit = limit or 72
    local here = 1
    local wrapped = str:gsub("(%s+)()(%S+)()", function(sp, st, word, fi)
        if fi-here > limit then
            here = st
            return "\n"..word
        end
    end)
    local splitted = {}
    for token in string.gmatch(wrapped, "[^\n]+") do
        splitted[#splitted + 1] = token
    end
    return splitted
end

local line
local fade_start
local base_time = N.base_time or 0
local current_talk

function start_anim()
    local duration = 15
    line = cluttered()
    line.go(
        "N.O/T.-MY-/D.E/[P/AR].T./M-E-/.N/T/",
        "TALK/ID-" .. current_talk.event_id,
        duration
    )
    fade_start = sys.now() + (duration/1.5)
end

function check_next_talk()
    local now = base_time + sys.now()
    local lineup = {}
    for idx, talk in ipairs(talks) do
        if talk.start + 600 > now and talk.place == saal then
            local changed = talk ~= current_talk
            current_talk = talk
            if changed then
                start_anim()
            end
            return
        end
    end
end

check_next_talk()

util.data_mapper{
    ["clock/set"] = function(time)
        base_time = tonumber(time) - sys.now()
        N.base_time = base_time
        check_next_talk()
        print("UPDATED TIME", base_time)
    end;
}


-- "TALK/ID-5059"
function node.render()
    gl.clear(0,0.02,0.2,1)
    bold:write(130, 430, line.get(), 50, 1,1,1,1)
    bold:write(130, 500, "2.9-C/3", 50, .5,.8,.5,1)

    local alpha = 0
    if sys.now() > fade_start then
        alpha = 1.0 / 3 * (sys.now() - fade_start)
        alpha = math.min(alpha, 1.0)
    end

    bold:write(600, 430, current_talk.nice_start, 50, 1,1,1,alpha)
    for idx, line in ipairs(wrap(current_talk.title, 40)) do
        if idx > 5 then
            break
        end
        regular:write(600, 450 + 60 * idx, line, 50, 1,1,1,alpha)
    end
    for i, speaker in ipairs(current_talk.speakers) do
        regular:write(600, 700 + 50 * i, speaker, 50, .5,.8,.5,alpha)
    end
end
