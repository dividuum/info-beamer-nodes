--[[

    A stoppable time source. From the same
    machine use

        echo -en "time/stop:" > /dev/udp/localhost/4444

    to stop the time. And

        echo -en "time/start:" > /dev/udp/localhost/4444

    to start the time again. While the
    time source if running or stopped you
    can rewind it to 0 by calling

        echo -en "time/rewind:" > /dev/udp/localhost/4444

]]--

local time = (function()
    local base = 0
    local stoppped = false

    local function now()
        if stopped then
            return base
        else
            return sys.now() - base
        end
    end;

    local function stop()
        if not stopped then
            base = now()
            stopped = true
        end
    end;

    local function start()
        if stopped then
            base = sys.now() - base
            stopped = false
        end
    end;

    local function rewind()
        if stopped then
            base = 0
        else
            base = sys.now()
        end
    end

    return {
        now = now;
        stop = stop;
        start = start;
        rewind = rewind;
    }
end)()

gl.setup(100, 100)

node.alias "time"

util.data_mapper{
    ["stop"]  = time.stop;
    ["start"] = time.start;
    ["rewind"] = time.rewind;
}

function node.render()
    print(time.now())
end
