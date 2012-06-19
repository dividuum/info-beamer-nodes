local INTERVAL = 7

gl.setup(1024, 768)

json = require "json"

util.resource_loader{
    "font.ttf";
    "white.png";
    "background.vert";
    "background.frag";
}

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

util.file_watch("tweets.json", function(content)
    tweets = json.decode(content)
    for idx, tweet in ipairs(tweets) do
        tweet.image = resource.load_image(tweet.image);
        tweet.lines = wrap(tweet.text, 35)
    end
end)

tweet_source = util.generator(function()
    return tweets
end)

function load_next()
    next_tweet = sys.now() + INTERVAL
    current_tweet = tweet_source:next()
end

load_next()

function node.render()
    background:use{ time = sys.now() }
    white:draw(0, 0, WIDTH, HEIGHT)
    background:deactivate()

    if sys.now() > next_tweet then
        load_next()
    end

    current_tweet.image:draw(50, 300, 130, 380)
    font:write(150, 230, current_tweet.time, 70, 1,1,1,1)
    font:write(150, 310, "@" .. current_tweet.user, 70, 1,1,1,1)
    for idx, line in ipairs(current_tweet.lines) do
        font:write(50, 350 + idx * 50, line, 50, 1,1,1,0.9)
    end
end
