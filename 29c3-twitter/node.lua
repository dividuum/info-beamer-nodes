gl.setup(1024, 768)

local json = require "json"

util.resource_loader{
    "light.ttf";
    "bold.ttf";
}

util.file_watch("hashtag", function(content)
    hashtag = content:gsub("([^\n]+).*", "%1")
end)

util.file_watch("tweets.json", function(content)
    tweets = {}
    for idx, tweet in ipairs(json.decode(content)) do
        tweet.image = resource.load_image(tweet.image)
        tweets[#tweets + 1] = tweet
    end
    table.sort(tweets, function(a,b) 
        return a.sec < b.sec
    end)
    return tweets
end)

tweet_source = util.generator(function()
    pp(tweets)
    return tweets
end)

local distort_shader = resource.create_shader([[
    void main() {
        gl_TexCoord[0] = gl_MultiTexCoord0;
        gl_FrontColor = gl_Color;
        gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    }
]], [[
    uniform sampler2D tex;
    uniform float effect;
    void main() {
        vec2 uv = gl_TexCoord[0].st;
        vec4 col;
        col.r = texture2D(tex,vec2(uv.x+sin(uv.y*20.0*effect)*0.2,uv.y)).r;
        col.g = texture2D(tex,vec2(uv.x+sin(uv.y*25.0*effect)*0.2,uv.y)).g;
        col.b = texture2D(tex,vec2(uv.x+sin(uv.y*30.0*effect)*0.2,uv.y)).b;
        col.a = texture2D(tex,vec2(uv.x,uv.y)).a;
        vec4 foo = vec4(1,1,1,effect);
        col.a = 1.0;
        gl_FragColor = gl_Color * col * foo;
    }
]])

function wrap(str, limit, indent, indent1)
    limit = limit or 72
    local here = 1
    local wrapped = str:gsub("(%s+)()(%S+)()", function(sp, st, word, fi)
        if fi-here > limit then
            here = st
            return "\n"..word
        end
    end)
    local splitted = {}
    for token in string.gmatch(wrapped, "[^\n]+") do
        splitted[#splitted + 1] = token
    end
    return splitted
end

local INTERVAL = 7

function load_next()
    next_tweet = sys.now() + INTERVAL
    current_tweet = tweet_source:next()
end

load_next()

function node.render()
    gl.clear(0,0.05,0.2,0)
    if sys.now() > next_tweet then
        load_next()
    end

    light:write(130, 20, "/" .. current_tweet.time .. "/" .. hashtag , 110, 1,1,1,1)
    util.draw_correct(current_tweet.image, 20, 20, 130, 130)
    bold:write(20, 180, "@" .. current_tweet.user, 90, 1,1,1,1)
    for idx, line in ipairs(wrap(current_tweet.text, 27)) do
        light:write(20, 220 + idx * 60, line, 60, 1,1,1,0.9)
    end

    if math.abs(next_tweet - 0.15 - sys.now()) < 0.3 then
        util.post_effect(distort_shader, {
            effect = math.abs(next_tweet - 0.15 - sys.now()) * 1.2
        })
    end
end
