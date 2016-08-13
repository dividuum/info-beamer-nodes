# What it does

Plays a video in a loop. When receiving a trigger signal,
show an intermission video. Once that's completed, return
back to the looping video.

# Installation

Add two video files called `loop.mp4` and `intermission.mp4`
to the current directory. The run info-beamer like this

```
$ info-beamer .
```

# Triggering the intermission video

You need to send `looper/set/intermission:` in a UDP packet
to info-beamer. This can be done like this:

```
echo -n "looper/set/intermission:" | netcat -u localhost 4444
```

You might even trigger the intermission using GPIO with a
shell script like this (untested):

```
#!/bin/bash
PIN=2
gpio mode $PIN in
while true; do
    if [ `gpio read $PIN` -eq 0 ]; then 
        echo -n "looper/set/intermission:" | netcat -u localhost 4444
    fi
    sleep 0.1
done
```

# Links

Originally used by MydKnight here:
https://github.com/MydKnight/Halloween2015

# Copyright

Public domain. Do whatever you want with this code.
