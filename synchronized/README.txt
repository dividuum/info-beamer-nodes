Synchronizing multiple nodes using external scripting

This example shows how you can control multiple nodes 
using external programs. The program consists of a master 
node that renders two child nodes. Two example programs
are provided that show how to synchronize a text output
in those two child nodes.

example_sender.sh requires the Bash shell.

example_sender.py requires python.

Both of them will synchronously update text in both child 
nodes by communicating with info-beamer using udp packets. 
This is the way to go if you want more complex behaviour 
from your nodes.
