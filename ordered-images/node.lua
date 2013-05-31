gl.setup(1920, 1080)

TIME_PER_IMAGE = 5

local images
local current_image_idx

function alphanumsort(o)
    local function padnum(d) return ("%03d%s"):format(#d, d) end
    table.sort(o, function(a,b)
        return tostring(a):gsub("%d+",padnum) < tostring(b):gsub("%d+",padnum) 
    end)
    return o
end

function init_images()
    images = {}
    for name, _ in pairs(CONTENTS) do
        if name:match(".*jpg") or name:match(".*png") then
            images[#images+1] = name
        end
    end
    current_image_idx = 0
    images = alphanumsort(images)
    pp(images)
end

function next_image()
    current_image_idx = current_image_idx + 1
    if current_image_idx > #images then
        current_image_idx = 1
    end
    image = resource.load_image(images[current_image_idx])
end

node.event("content_update", init_images)
node.event("content_remove", init_images)

init_images()

util.set_interval(TIME_PER_IMAGE, next_image)

function node.render()
    util.draw_correct(image, 0, 0, WIDTH, HEIGHT)
end
