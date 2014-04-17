gl.setup(1024, 768)

local font = resource.load_font("Ambrosia.otf")
local background = resource.load_image("7533495970_c159f75741_b.jpg")
local lines = {}

function wrap(str, limit, indent, indent1)
    indent = indent or ""
    indent1 = indent1 or indent
    limit = limit or 72
    function wrap_parargraph(str)
        local here = 1-#indent1
        return indent1..str:gsub("(%s+)()(%S+)()", function(sp, st, word, fi)
            if fi-here > limit then
                here = st - #indent
                return "\n"..indent..word
            end
        end)
    end
    local splitted = {}
    for par in string.gmatch(str, "[^\n]+") do
        local wrapped = wrap_parargraph(par)
        for line in string.gmatch(wrapped, "[^\n]+") do
            splitted[#splitted + 1] = line
        end
    end
    return splitted
end

util.file_watch("text.txt", function(content)
    lines = wrap(content, 60)
end)

function node.render()
    gl.clear(0, 0, 0, 1)
    background:draw(0, 0, WIDTH, HEIGHT, 0.6)
    y = 10
    for i, line in ipairs(lines) do
        local size = 50
        if i == 1 then
            size = 100
        end
        font:write(10, y, line, size, 1, 1, 1, 1)
        y = y + size
    end
end
