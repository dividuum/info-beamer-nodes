gl.setup(1024, 768)

function node.render()
    resource.render_child("child1"):draw(0, 0, 512, 768)
    resource.render_child("child2"):draw(512, 0, 1024, 768)
end
