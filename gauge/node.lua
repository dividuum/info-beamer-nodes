gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

local res = util.auto_loader()

local function gauge(conf)
    local x = conf.x
    local y = conf.y
    local size = conf.size or 150
    local value = 0
    local function draw()
        res.gauge:draw(x-size/2, y-size/2, x+size/2, y+size/2)
        gl.pushMatrix()
        gl.translate(x+0.5, y+0.5)
        gl.rotate(-135 + 271 * value, 0, 0, 1)
        res.needle:draw(-size/2, -size/2, size/2, size/2,0.8)
        gl.popMatrix()
    end
    local function set(new_value)
        value = new_value
    end
    return {
        draw = draw;
        set = set;
    }
end

node.alias("gauge")

local gauges = {
    foo = gauge{
        x = 300;
        y = 300;
        size = 300;
    };
    bar = gauge{
        x = 700;
        y = 300;
        size = 300;
    };
}

util.data_mapper{
    ["(.*)/set"] = function(gauge, value)
        gauges[gauge].set(tonumber(value))
    end
}

function node.render()
    gl.clear(1,1,1,1)
    for _, gauge in pairs(gauges) do
        gauge.draw()
    end
end
