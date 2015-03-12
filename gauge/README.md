Remote controllable gauges

Installation:

    Nothing to do. If you want to add more gauges,
    you can edit the lines in node.lua

Usage:

    You can update each of the defined gauges by
    sending udp packets to info-beamer. Each packet
    has to look like this:

    gauge/<gauge_id>/set:<value>

    For the default gauge settings in node.lua
    you can use this packet:

    gauge/foo/set:0.5

    To send this packet you can use for example
    bash to send it via udp to info-beamer:

    echo -n "gauge/foo/set:0.5" > /dev/udp/localhost/4444

    The value has to be in the range between 0
    and 1.

Copyright:

    The gauge and it's needle where extracted from the
    html/canvas sample at http://jsfiddle.net/dsmfg/3/
