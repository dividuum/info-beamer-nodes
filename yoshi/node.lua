gl.setup(NATIVE_WIDTH/2, NATIVE_HEIGHT/2)

local r = util.auto_loader()

local function mk_sprite(s)
    s.y = (s.y + 256) * 2
    return s
end

local sprites = {
    mk_sprite{img="oam20", x=0, y=-256, z=-30}, -- big mountain
    mk_sprite{img="oam22", x=0, y=-170, z=-30}, -- house big mountain
    mk_sprite{img="oam24", x=35, y=-256, z=-40},
    mk_sprite{img="oam24", x=35, y=-256, z=0},
    mk_sprite{img="oam24", x=-20, y=-256, z=-60}, -- mountain
    mk_sprite{img="oam8", x=-40, y=-256, z=0},
    mk_sprite{img="oam8", x=20, y=-256, z=-70}, -- green talus
    mk_sprite{img="oam3", x=-40, y=-256, z=-25}, -- red tower
    mk_sprite{img="oam51", x=-40, y=-256, z=-25, gr=1}, -- ground
    mk_sprite{img="oam5", x=-25, y=-256, z=-95}, -- volcano
    mk_sprite{img="oam32", x=60, y=-256, z=-60},
    mk_sprite{img="oam32", x=50, y=-256, z=40},
    mk_sprite{img="oam32", x=-40, y=-256, z=40}, -- hill
    mk_sprite{img="oam19", x=80, y=-256, z=-70},
    mk_sprite{img="oam19", x=80, y=-256, z=-40},
    mk_sprite{img="oam19", x=60, y=-256, z=60}, 
    mk_sprite{img="oam19", x=-60, y=-256, z=50},
    mk_sprite{img="oam19", x=-60, y=-256, z=20}, -- small hill
    mk_sprite{img="oam52", x=80, y=-256, z=-70, gr=1},
    mk_sprite{img="oam52", x=60, y=-256, z=60, gr=1}, 
    mk_sprite{img="oam52", x=-60, y=-256, z=50, gr=1}, -- green ground
    mk_sprite{img="oam14", x=50, y=-256, z=-20}, -- grey donjon
    mk_sprite{img="oam51", x=50, y=-256, z=-20, gr=1}, -- ground
    mk_sprite{img="oam14", x=0, y=-256, z=10}, -- grey donjon
    mk_sprite{img="oam50", x=0, y=-256, z=10, gr=1}, -- castle water
    mk_sprite{img="oam11", x=-12, y=-256, z=10},
    mk_sprite{img="oam11", x=12, y=-256, z=10},
    mk_sprite{img="oam11", x=0, y=-256, z=-2}, 
    mk_sprite{img="oam11", x=0, y=-256, z=22}, -- grey towers
    mk_sprite{img="oam28", x=60, y=-256, z=15}, -- towers with red roof
    mk_sprite{img="oam17", x=50, y=-256, z=-80}, -- dolmen
    mk_sprite{img="oam25", x=65, y=-256, z=30},
    mk_sprite{img="oam25", x=85, y=-256, z=30},
    mk_sprite{img="oam25", x=70, y=-256, z=10}, 
    mk_sprite{img="oam25", x=70, y=-256, z=-20}, -- oranges
    mk_sprite{img="oam10", x=0, y=-200, z=-70},
    mk_sprite{img="oam10", x=20, y=-180, z=-70},
    mk_sprite{img="oam10", x=40, y=-170, z=-50}, 
    mk_sprite{img="oam10", x=40, y=-190, z=-30}, -- cloud
    mk_sprite{img="oam35", x=-50, y=-160, z=-10}, -- cloud castle
    mk_sprite{img="oam2", x=-65, y=-256, z=-50},
    mk_sprite{img="oam2", x=-45, y=-256, z=-50},
    mk_sprite{img="oam2", x=-40, y=-256, z=-70},
    mk_sprite{img="oam2", x=-65, y=-256, z=-30}, 
    mk_sprite{img="oam2", x=-80, y=-256, z=-80},
    mk_sprite{img="oam2", x=-80, y=-256, z=-20},
    mk_sprite{img="oam2", x=-90, y=-256, z=0}, -- fir
    mk_sprite{img="oam1", x=-60, y=-256, z=-40},
    mk_sprite{img="oam1", x=-90, y=-256, z=-40},
    mk_sprite{img="oam1", x=-100, y=-256, z=-20},
    mk_sprite{img="oam1", x=-90, y=-256, z=-60}, 
    mk_sprite{img="oam1", x=-40, y=-256, z=-80},
    mk_sprite{img="oam1", x=-60, y=-256, z=-60},
    mk_sprite{img="oam1", x=-60, y=-256, z=-90}, -- small fir
    mk_sprite{img="oam23", x=60, y=-256, z=-40},
    mk_sprite{img="oam23", x=60, y=-256, z=-30},
    mk_sprite{img="oam23", x=60, y=-256, z=-90},
    mk_sprite{img="oam23", x=70, y=-256, z=-90}, 
    mk_sprite{img="oam23", x=50, y=-256, z=-95},
    mk_sprite{img="oam23", x=90, y=-256, z=-40},-- flower
    mk_sprite{img="oam23", x=95, y=-256, z=-50},
    mk_sprite{img="oam23", x=95, y=-256, z=-30},
    mk_sprite{img="oam23", x=80, y=-256, z=-20},
    mk_sprite{img="oam23", x=80, y=-256, z=-10}, 
    mk_sprite{img="oam23", x=100, y=-256, z=-10},
    mk_sprite{img="oam23", x=100, y=-256, z=0}, -- flower
    mk_sprite{img="oam6", x=30, y=-256, z=30},
    mk_sprite{img="oam6", x=20, y=-256, z=40},
    mk_sprite{img="oam6", x=20, y=-256, z=60},
    mk_sprite{img="oam6", x=-20, y=-256, z=30}, 
    mk_sprite{img="oam6", x=-20, y=-256, z=50},
    mk_sprite{img="oam6", x=-30, y=-256, z=60},
    mk_sprite{img="oam6", x=-10, y=-256, z=90}, -- tree
    mk_sprite{img="oam9", x=30, y=-256, z=45},
    mk_sprite{img="oam9", x=35, y=-256, z=60},
    mk_sprite{img="oam9", x=45, y=-256, z=70},
    mk_sprite{img="oam9", x=50, y=-256, z=90}, 
    mk_sprite{img="oam9", x=-20, y=-256, z=90},
    mk_sprite{img="oam9", x=-15, y=-256, z=70},
    mk_sprite{img="oam9", x=-10, y=-256, z=35}, -- small tree
    mk_sprite{img="oam16", x=0, y=-256, z=30},
    mk_sprite{img="oam16", x=0, y=-256, z=40},
    mk_sprite{img="oam16", x=0, y=-256, z=50}, 
    mk_sprite{img="oam16", x=0, y=-256, z=60},
    mk_sprite{img="oam16", x=0, y=-256, z=70}, -- plots
    mk_sprite{img="oam4", x=-25, y=-220, z=-95, mz=20},
    mk_sprite{img="oam4", x=-25, y=-210, z=-95, mz=20}, -- volcano smoke
    mk_sprite{img="oam33", x=-10, y=-172, z=-23},
    mk_sprite{img="oam33", x=-15, y=-169, z=-21},
    mk_sprite{img="oam33", x=-20, y=-166, z=-19}, 
    mk_sprite{img="oam33", x=-25, y=-163, z=-17},
    mk_sprite{img="oam33", x=-30, y=-160, z=-15}, -- chain
    mk_sprite{img="oam38", x=20, y=-200, z=40, mz=2}, -- seagull
    mk_sprite{img="oam18", x=20, y=-256, z=50} -- Yoshi
}

for i = 1, 30 do
    local r = math.random() * 120
    local a = math.random() * math.pi * 2
    sprites[#sprites+1] = mk_sprite{
        img = "oam27",
        x = r * math.cos(a),
        y = -256,
        z = r * math.sin(a),
    }
end

local function prepare()
    for i = 1, #sprites do
        local s = sprites[i]
        local img = r[s.img]
        if not s.sw then
            local w, h = img:size()
            if w > 1 and h > 1 then
                s.sw, s.sh = w, h
                if s.gr then
                    s.sh = s.sh / 1.5
                end
            else
                return false
            end
        end
    end
    return true
end

local function update()
    local now = sys.now()
    local sin = math.sin(now)
    local cos = math.cos(now)
    local cx = WIDTH / 2
    local cy = HEIGHT / 1.5
    for i = 1, #sprites do
        local s = sprites[i]
        local img = r[s.img]
        local x = (s.x * cos - s.z * sin) * 2.5
        local z = (s.z * cos + s.x * sin) * 2.5
        local step_y = 0
        if s.mz then
            step_y = math.floor((now * 60) % s.mz) * 2
        end
        s.draw_x = cx + x - s.sw/2
        s.draw_y = cy - s.y - s.sh - z/3 - step_y
        s.z_index = z + i*0.01
        
        if s.gr then
            s.z_index = 100000
            s.draw_y = s.draw_y + s.sh/2
        end
    end
    table.sort(sprites, function(s1, s2)
        return s1.z_index > s2.z_index 
    end)
end

local function draw()
    for i = 1, #sprites do
        local s = sprites[i]
        r[s.img]:draw(s.draw_x, s.draw_y, s.draw_x + s.sw, s.draw_y + s.sh)
    end
end

-- r.map = resource.create_colored_texture(1, 0, 0, 1)

function node.render()
    gl.clear(0, 0, 0, 0)
    local lft = (sys.now() * 90) % WIDTH
    r.map:draw(-lft, HEIGHT/5, -lft + WIDTH, HEIGHT/5*2)
    r.map:draw(-lft + WIDTH, HEIGHT/5, -lft + WIDTH*2, HEIGHT/5*2)

    if prepare() then
        update()
        draw()
    end
end
