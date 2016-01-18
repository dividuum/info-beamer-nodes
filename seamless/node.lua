-- Display time for all images
local IMAGE_TIME = 10

----------------------------------------------------------

gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

local function cycled(items, offset)
    offset = offset % #items + 1
    return items[offset], offset
end

local function image(filename)
    local img, start
    return {
        prepare = function()
            img = resource.load_image(filename)
        end;
        start = function()
            start = sys.now()
        end;
        draw = function()
            util.draw_correct(img, 0, 0, WIDTH, HEIGHT)
            return sys.now() - start < IMAGE_TIME
        end;
        dispose = function()
            img:dispose()
        end;
    }
end

local function video(filename)
    local vid, start
    return {
        prepare = function()
            print "video prepare"
            local raw = sys.get_ext "raw_video"
            vid = raw.load_video(filename, true, false, true)
        end;
        start = function()
            print "video start"
        end;
        draw = function()
            local state, width, height = vid:state()
            if state == "paused" then
                local x1, y1, x2, y2 = util.scale_into(WIDTH, HEIGHT, width, height)
                vid:target(x1, y1, x2, y2):start()
            end
            return state ~= "finished" and state ~= "error"
        end;
        dispose = function()
            print "video dispose"
            vid:dispose()
        end;
    }
end

local function Runner(scheduler)
    local cur, nxt, old

    local function prepare()
        assert(not nxt)
        nxt = scheduler.get_next()
        nxt.prepare()
    end
    local function down()
        assert(not old)
        old = cur
        cur = nil
    end
    local function switch()
        assert(nxt)
        cur = nxt
        cur.start()
        nxt = nil
    end
    local function dispose()
        if old then
            old.dispose()
            old = nil
        end
    end

    local function tick()
        if not nxt then
            prepare()
        end
        dispose()
        if not cur then
            switch()
        end
        if not cur.draw() then
            down()
        end
    end

    return {
        tick = tick;
    }
end

local function Scheduler()
    local medias = {}
    local medialist = {}

    local function update_list()
        medialist = {}
        for filename, media in pairs(medias) do
            medialist[#medialist+1] = media
        end
        table.sort(medialist, function(a,b)
            return a.sort_key < b.sort_key
        end)
    end

    local prefix_map = {
        ["img_"] = image;
        ["vid_"] = video;
    }

    node.event("content_update", function(filename)
        local handler = prefix_map[filename:sub(1, 4)]
        if handler then
            medias[filename] = {
                handler = handler,
                file = resource.open_file(filename),
                filename = filename,
                sort_key = filename:sub(5),
            }
            update_list()
        end
    end)

    node.event("content_remove", function(filename)
        if medias[filename] then
            medias[filename].file:dispose()
            medias[filename] = nil
            update_list()
        end
    end)

    local media_idx = 0

    local function print_playlist()
        print "-------[ playing ]---------"
        for idx = 1, #medialist do
            print(("%5s %s"):format(idx == media_idx and "-->" or "", medialist[idx].filename))
        end
        print "---------------------------"
    end

    local function get_next()
        print_playlist()
        local media
        media, media_idx = cycled(medialist, media_idx)
        return media.handler(media.file:copy())
    end

    return {
        get_next = get_next;
    }
end

local scheduler = Scheduler()
local runner = Runner(scheduler)

assert(sys.provides "openfile", "info-beamer pi version required")


function node.render()
    runner.tick()
end
