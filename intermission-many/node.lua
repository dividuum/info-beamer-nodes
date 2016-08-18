gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

local raw = sys.get_ext "raw_video"
local loop = raw.load_video{file="loop.mp4", looped=true}

local function pause_loop()
    loop:target(-1, -1, -1, -1):stop()
end

local function play_loop()
    loop:target(0, 0, WIDTH, HEIGHT):layer(-2):start()
end

local intermission
local next_intermission

node.alias "looper"

util.data_mapper{
    play = function(file)
        -- load the next intermission. If there is already one
        -- loading, abort loading now and replace it with the
        -- new video.
        if next_intermission then
            next_intermission:dispose()
        end
        next_intermission = raw.load_video(file)
        next_intermission:target(0, 0, WIDTH, HEIGHT):layer(-3)
    end
}

play_loop()

function node.render()
    gl.clear(0,0,0,0)
    if next_intermission and next_intermission:state() == "loaded" then
        -- next intermission finished loading? Then stop any
        -- intermission that is currently running and replace
        -- it with the next one.
        if intermission then
            intermission:dispose()
        end
        intermission = next_intermission
        intermission:layer(-1)
        next_intermission = nil
        pause_loop()
    end

    if intermission and intermission:state() ~= "loaded" then
        -- intermission running and it ended? Then get rid of
        -- the intermission video and resume playing the main
        -- loop.
        intermission:dispose()
        intermission = nil
        play_loop()
    end
end
