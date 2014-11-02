An analog dial
--------------

It's a quick hack on how you might build an analog dial like it was used in old radios. It's a
response to http://www.raspberrypi.org/forums/viewtopic.php?f=67&t=90615

To use this visualization you probably should change the font and create a nicer front.png. But you
should get the idea :-)

You can set the current rotation by sending float values to the running info-beamer instance. values
are offsets into the list of items defined in items.json. Values between 0 and 1 (exclusive) show
the first item selected. 0.5 centers the first item. The number of items is not limited. So you can
have more items that would be physically possible.

Sending the rotation works by simple sending simple UDP packets. To learn more about how this works,
have a look at https://info-beamer.com/blog/combining-lua-and-python-to-show-bitcoin-exchange-rates

The script set_item shows how to send data. It works like this:

$ ./set_item 0.5
