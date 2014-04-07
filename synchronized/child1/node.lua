gl.setup(512, 768)

font = resource.load_font("silkscreen.ttf")

text = "<unset>"

util.data_mapper{
    ["set_text"] = function(new_text)
        text = new_text
    end
}

print "Hello from node child1"

function node.render()
    gl.clear(0.3, 0, 0, 1)
    font:write(10, 100, "this is child1", 50, 1, 1, 1, 1)
    font:write(10, 200, "current value of text: " .. text, 20, 1, 1, 1, 1)
end
