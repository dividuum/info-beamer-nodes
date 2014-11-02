gl.setup(1024, 768)

node.alias "radio"

local json = require "json"

local font = resource.load_font "silkscreen.ttf"
local front = resource.load_image "front.png"

local center = {
    x = WIDTH / 2;
    y = HEIGHT /2;
}

local radius = 290
local font_size = 50
local angle_per_item = 40

local items
util.file_watch("items.json", function(data)
    items = json.decode(data)
    for _, item in ipairs(items) do
        item.offset = -font:width(item.text, font_size) / 2
    end
end)

local angle = 0
util.data_mapper{
    set = function(float_idx)
        angle = tonumber(float_idx) * angle_per_item
    end
}

function node.render()
    local current_idx = math.floor((angle / angle_per_item) % #items)
    local relative_rot = -(angle % angle_per_item) 

    local around = 2
    local rot = relative_rot - around * angle_per_item + angle_per_item / 2
    for offset = -around, around do
        idx = (current_idx + offset) % #items

        gl.pushMatrix()
        gl.translate(center.x, center.y, 0)
        gl.rotate(rot, 0, 0, 1)
        gl.translate(0, -radius, 0)

        local item = items[idx+1]
        if idx == current_idx then
            font:write(item.offset, 0, item.text, font_size, 1,1,1,1)
        else
            font:write(item.offset, 0, item.text, font_size, .5,.5,.5,1)
        end

        gl.popMatrix()

        rot = rot + angle_per_item
    end

    front:draw(center.x - 300, center.y - 300, center.x + 300, center.y + 300)
end
