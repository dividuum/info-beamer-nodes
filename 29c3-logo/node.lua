gl.setup(600, 600)

local scramble = require "scramble"

util.auto_loader(_G)

function write(font, x, y, text, size, r, g, b, a)
    local s = scramble.scramble(text)
    return function()
        font:write(x, y, s(), size, r, g, b, a)
    end
end

local lines = {
    write(light, 50, 0 * 115, "N/O.T[M", 120, 1,1,1,1),
    write(light, 50, 1 * 115, "Y.D/E]P", 120, 1,1,1,1),
    write(light, 50, 2 * 115, "A.R-T/M", 120, 1,1,1,1),
    write(light, 50, 3 * 115, "E/N-T..", 120, 1,1,1,1),
    write(bold,  50, 4 * 115, "2(9)C-3", 120, 1,1,1,1),
}

function node.render()
    for i = 1, #lines do
        lines[i]()
    end
end
