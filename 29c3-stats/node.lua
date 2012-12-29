gl.setup(1024, 768)

local interval = 5

local json = require "json"

util.loaders.json = function(filename)
    return json.decode(resource.load_file(filename))
end

util.auto_loader(_G)

local stats = {
    function ()
        bold:write(10, 150, "GSM", 150, 1,1,1,1)
        regular:write(10, 350, gsm.active_subscribers .. " subscribers", 90, 1,1,1,1)
        regular:write(10, 450, gsm.sms_delivered.. " SMS delivered", 90, 1,1,1,1)
    end;
    function ()
        bold:write(10, 150, "Wlan", 150, 1,1,1,1)
        regular:write(10, 350, dash.clients.value[2] .. " Clients", 100, 1,1,1,1)
    end;
    function ()
        bold:write(10, 150, "POC", 150, 1,1,1,1)
        regular:write(10, 350, dash.poc.value[1] .. " Phones", 100, 1,1,1,1)
    end;
    function ()
        bold:write(10, 150, "Bandwidth", 150, 1,1,1,1)
        regular:write(10, 350, dash.bw.value[1] .. " Mbps down", 100, 1,1,1,1)
        regular:write(10, 450, dash.bw.value[2] .. " Mbps up", 100, 1,1,1,1)
    end;
}

function node.render()
    stats[math.floor((sys.now() / interval) % #stats)+1]()
end
