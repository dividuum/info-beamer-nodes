local INTERVAL = 10

gl.setup(1920, 1080)

pictures = util.generator(function()
    local out = {}
    for name, _ in pairs(CONTENTS) do
        if name:match(".*jpg") then
            out[#out + 1] = name
        end
    end
    return out
end)
node.event("content_remove", pictures.remove)

util.set_interval(INTERVAL, function()
    local next_image_name = pictures.next()
    print("now showing " .. next_image_name)
    last_image = current_image
    current_image = resource.load_image(next_image_name)
    fade_start = sys.now()
end)

function node.render()
    gl.clear(0,0,0,1)
    local delta = sys.now() - fade_start
    if delta < 1 and last_image then
        util.draw_correct(last_image, 0, 0, WIDTH, HEIGHT, 1 - delta)
        util.draw_correct(current_image, 0, 0, WIDTH, HEIGHT, delta)
    else
        util.draw_correct(current_image, 0, 0, WIDTH, HEIGHT)
    end
end
