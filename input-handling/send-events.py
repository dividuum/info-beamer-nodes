import socket
import json
from select import select

from evdev import ecodes, InputDevice, list_devices

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
INFOBEAMER_ADDR = ('127.0.0.1', 4444)

devices = [InputDevice(d) for d in list_devices("/dev/input/")]

for device in devices:
    print device.name
print
print "sending events to info-beamer at %s:%d" % INFOBEAMER_ADDR

def send_event(device, event):
    if event.type == ecodes.EV_SYN:
        return

    if event.type in ecodes.bytype:
        codename = ecodes.bytype[event.type][event.code]
    else:
        codename = '?'

    sock.sendto("input-example/event:%s" % json.dumps(dict(
        device = device.name,
        timestamp = event.timestamp(),
        type = ecodes.EV[event.type],
        code = codename,
        value = event.value
    )), INFOBEAMER_ADDR)

while 1:
    r, w, e = select(devices, [], [])
    for device in r:
        for ev in device.read():
            send_event(device, ev)

