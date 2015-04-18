A flap display emulation
========================

You need at least version 0.9 pre6 of info-beamer pi
to use this visualization.

You can change what's displayed by connecting to
the local info-beamer process using TCP:

# netcat localhost 4444
Info Beamer PI 0.9.0-beta-pre6.a5037a (https://info-beamer.com) ...
display
ok!
connected
Hello display

You can of course automatically send information to info-beamer.
Even using just the (bash) shell:

all in one line:
(echo -en "display\n"; while true; do echo "##go_up##"; head -n 10 /proc/meminfo; sleep 1; done) > /dev/tcp/localhost/4444

You must send your data encoded as latin1. The following letters are valid:
' abcdefghijklmnopqrstuvwxyzäöü0123456789@#-.,:?!()'

letters.png created by https://github.com/MichaelKreil
