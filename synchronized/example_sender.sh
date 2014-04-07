#!/bin/bash
# Easiest way to send to both child nodes from a Bash shell script that
# supports the /dev/udp/* syntax.

while true; do
    echo -n "synchronized/child1/set_text:Hello" > /dev/udp/localhost/4444
    echo -n "synchronized/child2/set_text:Hello" > /dev/udp/localhost/4444
    sleep 1
    echo -n "synchronized/child1/set_text:World" > /dev/udp/localhost/4444
    echo -n "synchronized/child2/set_text:from bash" > /dev/udp/localhost/4444
    sleep 1
done
