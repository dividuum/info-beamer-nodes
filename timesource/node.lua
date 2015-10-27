--[[

    A stoppable time source. From the same
    machine use

        echo -en "time/stop:" > /dev/udp/localhost/4444

    to stop the time. And

        echo -en "time/start:" > /dev/udp/localhost/4444

    to start the time again.

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

    return {
        now = now;
        stop = stop;
        start = start;
    }
end)()

gl.setup(100, 100)

node.alias "time"

util.data_mapper{
    ["stop"]  = time.stop;
    ["start"] = time.start;
}

function node.render()
    print(time.now())
end
