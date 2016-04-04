A dynamic led street sign
-------------------------

Edit content.json to change the automatically rotated
sign content.

You can interrupt the automated content by sending
a UDP packet to info-beamer on port 4444:

echo -n "sign/add/10:message" | netcat -u localhost 4444

The 10 is the number of seconds the message will be
displayed. Feel free to change that.

You can replace 'message' with a longer string of course
which will wrap around to the next line at every 18th
characters.

As there are a total of 8 rows, each with 18 characters,
your message should not exceed a total length of 18x8=144
characters as any character beyond that limit will be
ignored. So just think of twitter when you compose
a message ;-)

You can enqueue multiple messages that way. They will
be displayed in order of receipt. Once the last message
was displayed the sign will return to it's automated
rotation as defined in content.json.

The provided font only supports a limited range of
ascii characters. See http://www.dafont.com/ballplay.font
