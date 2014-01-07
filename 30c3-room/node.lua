gl.setup(1280, 720)

node.alias("room")

local json = require "json"

-- Configure room here
local SAAL = "Saal 1"

util.auto_loader(_G)

util.file_watch("schedule.json", function(content)
    print("reloading schedule")
    talks = json.decode(content)
end)

util.file_watch("config.json", function(content)
    local config = json.decode(content)
    if sys.get_env then
        saal = config.devices[sys.get_env("SERIAL")]
    end
    if not saal then
        print("using statically configured saal identifier")
        saal = SAAL
    end
    print(saal)
    rooms = config.rooms
    room = config.rooms[saal]
end)

local base_time = N.base_time or 0
local current_talk
local all_talks = {}
local day = 0

vortex = (function()
    local function draw()
        local time = sys.now()
        trichter:use{
            Overlay = _G[room.texture];
            Grid = trichter_grid;
            time = time/room.speed;
        }
        trichter_map:draw(-150, 0, WIDTH+150, HEIGHT)
        trichter:deactivate()
    end
    return {
        draw = draw;
    }
end)()

function get_now()
    return base_time + sys.now()
end

function check_next_talk()
    local now = get_now()
    local room_next = {}
    for idx, talk in ipairs(talks) do
        if rooms[talk.place] and not room_next[talk.place] and talk.unix + 25 * 60 > now then 
            room_next[talk.place] = talk
        end
    end

    for room, talk in pairs(room_next) do
        talk.lines = wrap(talk.title, 30)
    end

    if room_next[saal] then
        current_talk = room_next[saal]
    else
        current_talk = nil
    end

    all_talks = {}
    for room, talk in pairs(room_next) do
        if current_talk and room ~= current_talk.place then
            all_talks[#all_talks + 1] = talk
        end
    end
    table.sort(all_talks, function(a, b) 
        if a.unix < b.unix then
            return true
        elseif a.unix > b.unix then
            return false
        else
            return a.place < b.place
        end
    end)
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

local clock = (function()
    local base_time = N.base_time or 0

    local function set(time)
        base_time = tonumber(time) - sys.now()
    end

    util.data_mapper{
        ["clock/midnight"] = function(since_midnight)
            set(since_midnight)
        end;
    }

    local left = 0

    local function get()
        local time = (base_time + sys.now()) % 86400
        return string.format("%d:%02d", math.floor(time / 3600), math.floor(time % 3600 / 60))
    end

    return {
        get = get;
        set = set;
    }
end)()

check_next_talk()

util.data_mapper{
    ["clock/set"] = function(time)
        base_time = tonumber(time) - sys.now()
        N.base_time = base_time
        check_next_talk()
        print("UPDATED TIME", base_time)
    end;
    ["clock/day"] = function(new_day)
        print("DAY", new_day)
        day = new_day
    end;
}

function switcher(screens)
    local current_idx = 1
    local current = screens[current_idx]
    local switch = sys.now() + current.time
    local switched = sys.now()

    local blend = 0.5
    
    local function draw()
        local now = sys.now()

        local percent = ((now - switched) / (switch - switched)) * 3.14129 * 2 - 3.14129
        progress:use{percent = percent}
        white:draw(WIDTH-50, HEIGHT-50, WIDTH-10, HEIGHT-10)
        progress:deactivate()

        if now - switched < blend then
            local delta = (switched - now) / blend
            gl.pushMatrix()
            gl.translate(WIDTH/2, 0)
            gl.rotate(270-90 * delta, 0, 1, 0)
            gl.translate(-WIDTH/2, 0)
            current.draw()
            gl.popMatrix()
        elseif now < switch - blend then
            current.draw(now - switched)
        elseif now < switch then
            local delta = 1 - (switch - now) / blend
            gl.pushMatrix()
            gl.translate(WIDTH/2, 0)
            gl.rotate(90 * delta, 0, 1, 0)
            gl.translate(-WIDTH/2, 0)
            current.draw()
            gl.popMatrix()
        else
            current_idx = current_idx + 1
            if current_idx > #screens then
                current_idx = 1
            end
            current = screens[current_idx]
            switch = now + current.time
            switched = now
        end
    end
    return {
        draw = draw;
    }
end

content = switcher{
    {
        time = 10;
        draw = function()
            font:write(400, 200, "Other rooms", 80, 1,1,1,1)
            white:draw(0, 300, WIDTH, 302, 0.6)
            y = 320
            local time_sep = false
            if #all_talks > 0 then
                for idx, talk in ipairs(all_talks) do
                    if not time_sep and talk.unix > get_now() then
                        if idx > 1 then
                            y = y + 5
                            white:draw(0, y, WIDTH, y+2, 0.6)
                            y = y + 20
                        end
                        time_sep = true
                    end

                    local alpha = 1
                    if not time_sep then
                        alpha = 0.3
                    end
                    font:write(30, y, talk.start, 50, 1,1,1,alpha)
                    font:write(190, y, talk.place, 50, 1,1,1,alpha)
                    font:write(400, y, talk.lines[math.floor((sys.now()/2) % #talk.lines)+1], 50, 1,1,1,alpha)
                    y = y + 60
                end
            else
                font:write(400, 330, "No other talks.", 50, 1,1,1,1)
            end
        end
    }, {
        time = 30;
        draw = function()
            if not current_talk then
                font:write(400, 200, "Next talk", 80, 1,1,1,1)
                white:draw(0, 300, WIDTH, 302, 0.6)
                font:write(400, 330, "Nope. That's it.", 50, 1,1,1,1)
            else
                local delta = current_talk.unix - get_now()
                if delta > 0 then
                    font:write(400, 200, "Next talk", 80, 1,1,1,1)
                else
                    font:write(400, 200, "This talk", 80, 1,1,1,1)
                end
                white:draw(0, 300, WIDTH, 302, 0.6)

                font:write(130, 330, current_talk.start, 50, 1,1,1,1)
                if delta > 0 then
                    font:write(130, 330 + 60, string.format("in %d min", math.floor(delta/60)+1), 50, 1,1,1,0.8)
                end
                for idx, line in ipairs(current_talk.lines) do
                    if idx >= 5 then
                        break
                    end
                    font:write(400, 330 - 60 + 60 * idx, line, 50, 1,1,1,1)
                end
                for i, speaker in ipairs(current_talk.speakers) do
                    font:write(400, 510 + 50 * i, speaker, 50, 0,0.8,0.9,1.0)
                end
            end
        end
    }, {
        time = 10;
        draw = function(t)
            font:write(400, 200, "Room info", 80, 1,1,1,1)
            white:draw(0, 300, WIDTH, 302, 0.6)
            font:write(30, 320, "Audio", 50, 1,1,1,1)
            font:write(400, 320, "Dial " .. room.dect, 50, 1,1,1,1)

            font:write(30, 380, "Translation", 50, 1,1,1,1)
            font:write(400, 380, "Dial " .. room.translation, 50, 1,1,1,1)

            font:write(30, 480, "IRC", 50, 1,1,1,1)
            font:write(400, 480, room.irc, 50, 1,1,1,1)

            font:write(30, 540, "Twitter", 50, 1,1,1,1)
            font:write(400, 540, room.twitter, 50, 1,1,1,1)

            if t then
                local banner = -4 + t
                if banner > 0 and banner < 3.1412 then
                    local alpha = math.pow(math.sin(banner), 2)
                    local x = 400 - math.pow(banner / math.pi - 0.5, 5) * WIDTH * 2
                    font:write(x, 640, "http://info-beamer.org/", 30, 1,1,1,alpha)
                end
            end
        end
    },
}

function node.render()
    vortex.draw()

    if base_time == 0 then
        return
    end

    util.draw_correct(logo, 20, 20, 300, 120)
    font:write(310, 20, saal, 100, 1,1,1,1)
    font:write(650, 20, clock.get(), 100, 1,1,1,1)
    font:write(WIDTH-300, 20, string.format("Day %d", day), 100, 1,1,1,1)

    local fov = math.atan2(HEIGHT, WIDTH*2) * 360 / math.pi
    gl.perspective(fov, WIDTH/2, HEIGHT/2, -WIDTH,
                        WIDTH/2, HEIGHT/2, 0)
    content.draw()
end
