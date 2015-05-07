gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

local NUM_COLUMNS = 5
local SPEED = 80

local IMAGE_WIDTH = WIDTH / NUM_COLUMNS
local IMAGE_HEIGHT = HEIGHT / NUM_COLUMNS

local function alphanumsort(o)
    local function padnum(d) return ("%03d%s"):format(#d, d) end
    table.sort(o, function(a,b)
        return tostring(a):gsub("%d+",padnum) < tostring(b):gsub("%d+",padnum)
    end)
    return o
end

local pictures = util.generator(function()
    local files = {}
    for name, _ in pairs(CONTENTS) do
        if name:match(".*jpg") or name:match(".*png") then
            files[#files+1] = name
        end
    end
    return alphanumsort(files) -- sort files by filename
end)

node.event("content_remove", function(filename)
    pictures:remove(filename)
end)

local Image = function(file)
    local res = resource.load_image(file)
    local alpha = 0

    local function tick(dt)
        if res:state() == "loaded" then
            alpha = math.min(1.0, alpha + dt)
        end
    end

    local function draw(x, y)
        util.draw_correct(res, x+5, y, x+IMAGE_WIDTH-10, y+IMAGE_HEIGHT, alpha)
    end

    local function unload()
        res:dispose()
    end

    return {
        tick = tick;
        draw = draw;
        unload = unload;
    }
end

local Column = function(x)
    local images = {}

    local function tick(dt)
        local y = 0
        for i = 1, #images do
            local image = images[i]
            image.obj.tick(dt)
            image.y = image.y - dt * SPEED
            y = image.y + IMAGE_HEIGHT
        end

        while y < HEIGHT + SPEED do
            local img_y = y + 10 + math.random() * 20;
            images[#images+1] = {
                y = img_y;
                obj = Image(pictures.next());
            }
            y = img_y + IMAGE_HEIGHT + 10
        end

        assert(#images > 0)

        while true do
            local image = images[1]
            if image.y < -IMAGE_HEIGHT then
                image.obj.unload()
                table.remove(images, 1)
            else
                break
            end
        end
    end

    local function draw()
        for i = 1, #images do
            local image = images[i]
            image.obj.draw(x, image.y)
        end
    end

    return {
        tick = tick;
        draw = draw;
    }
end

local Columns = function()
    local columns = {}

    for i = 1, NUM_COLUMNS do
        columns[#columns+1] = Column((i-1)*IMAGE_WIDTH)
    end

    local function tick(dt)
        for i = 1, NUM_COLUMNS do
            columns[i].tick(dt)
        end
    end

    local function draw()
        for i = 1, NUM_COLUMNS do
            columns[i].draw()
        end
    end

    return {
        tick = tick;
        draw = draw;
    }
end

local columns = Columns()

local old = sys.now()
function node.render()
    local now = sys.now()
    local dt = now - old
    old = now

    columns.tick(dt)
    columns.draw()
end
