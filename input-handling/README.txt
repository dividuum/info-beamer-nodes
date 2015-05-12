Handling device input
---------------------

info-beamer doesn't support input devices. This is by design
since there are so many different device that you might want
to use and info-beamer cannot support all of them. So input
devices are handled by an external program.

This makes it easier to simulate input and also enables you
to capture and send device input over the network.

This small example shows how this might work.

Installation
------------

You'll need python and the evdev[1] library. On the Pi,
follow these steps:

Install evdev

 $ apt-get install python-pip
 $ pip install evdev

Run the provided send-events.py Python program:

 $ python send-events.py

Keep the program running and start info-beamer:
 
 $ info-beamer .

You should see a mouse pointer on the screen that you can
move with a mouse connected to the Pi.


Copyright
---------

pointer.png was created by lancel. See [2]

[1] https://python-evdev.readthedocs.org/en/latest/
[2] http://opengameart.org/content/knights-glove-mouse-cursor
