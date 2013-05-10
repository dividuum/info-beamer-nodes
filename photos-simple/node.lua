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
    current_image = resource.load_image(next_image_name)
end)

function node.render()
    gl.clear(0,0,0,1)
    util.draw_correct(current_image, 0, 0, WIDTH, HEIGHT)
end
