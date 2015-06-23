gl.setup(1920, 1080)

local playlist, video, current_video_idx

util.file_watch("playlist.txt", function(content) 
    playlist = {}
    for filename in string.gmatch(content, "[^\r\n]+") do
        playlist[#playlist+1] = filename
    end
    current_video_idx = 0
    print("new playlist")
    pp(playlist)
end)

function next_video()
    current_video_idx = current_video_idx + 1
    if current_video_idx > #playlist then
        current_video_idx = 1
    end
    if video then
        video:dispose()
    end
    video = util.videoplayer(playlist[current_video_idx], {loop=false})
end

function node.render()
    if not video or not video:next() then
        next_video()
    end
    util.draw_correct(video, 0, 0, WIDTH, HEIGHT)
end
