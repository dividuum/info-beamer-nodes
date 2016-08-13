gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)
node.alias "looper"

-- This version uses low level video playback 
-- if this line isn't commented.
local raw = sys.get_ext "raw_video"

if raw then
    loader = raw.load_video
else
    loader = resource.load_video
end

local Looper = function(file)
    local vid = loader(file, true, true)
    local function draw()
        if not raw then
            util.draw_correct(vid, 0, 0, WIDTH, HEIGHT)
        end
        return true
    end
    local function set_running(running)
        if running then
            if raw then vid:target(0, 0, WIDTH, HEIGHT):layer(-1) end
            vid:start()
        else
            vid:stop()
            if raw then vid:target(0, 2000, 0, 2000) end -- move video layer away
        end
    end
    return {
        draw = draw;
        set_running = set_running;
    }
end

local Intermission = function(file)
    local vid = resource.create_colored_texture(0, 0, 0, 0)
    local function draw()
        if not raw then
            util.draw_correct(vid, 0, 0, WIDTH, HEIGHT)
        end
        return vid:state() ~= "finished"
    end
    local function preload()
        if vid then vid:dispose() end
        vid = loader(file, true, false, true)
    end
    local function set_running(running)
        if running then
            if raw then vid:target(0, 0, WIDTH, HEIGHT):layer(-1) end
            vid:start()
        else
            preload()
        end
    end

    preload()

    return {
        draw = draw;
        set_running = set_running;
    }
end

local loop = Looper "loop.mp4"
local intermission = Intermission "intermission.mp4"

local surface

local function start_loop()
    loop.set_running(true)
    intermission.set_running(false)
    surface = loop
end

local function start_intermission()
    intermission.set_running(true)
    loop.set_running(false)
    surface = intermission
end

util.data_mapper{
    ["set"] = function(new_mode)
        if new_mode == "loop" then
            start_loop()
        else
            start_intermission()
        end
    end;
}

start_loop()

function node.render()
    gl.clear(0, 0, 0, 0)
    if not surface.draw() then
        start_loop()
    end
end
