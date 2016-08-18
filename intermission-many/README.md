# Interruptable video looper

This code plays `loop.mp4` in a loop until you tell it to interrupt with
another intermission video file.

## Interrupting playback

Send a udp message to info-beamer containing the filename of the video.
Using `netcat` works like this:

```
echo -n "looper/play:intermission.mp4" | netcat -u localhost 4444
```

Of course you can send that packet from any other programming language
with the ability to send UDP packets.

Triggering an intermission video while another intermission video is
already running works and will replace the running intermission
video.
