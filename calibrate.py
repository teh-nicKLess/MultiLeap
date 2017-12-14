#!/usr/bin/python

import sys
import json
import numpy as np

if sys.version_info[0] > 2:
    raise Exception("Only python 2 currently")

import websocket


def on_message(ws, message):
    data = json.loads(message)
    tools = []
    for p in data["pointables"]:
        if p["tool"]:
            tools.append([np.array(p["stabilizedTipPosition"]), np.array(p["direction"])])
    if len(tools) != 2:
        return

    pos0 = 0.001 * np.array(tools[0][0])
    pos1 = 0.001 * np.array(tools[1][0])
    dir0 = np.array(tools[0][1])
    dir1 = np.array(tools[1][1])

    position = ((pos0 - 0.15 * dir0) + (pos1 - 0.15 * dir1)) / 2
    direction = pos1 - pos0
    direction = direction / np.linalg.norm(direction)
    tmp = position-pos0
    normal = np.cross(tmp, direction)
    normal = normal / np.linalg.norm(normal)

    print "position:", position
    print "direction:", direction
    print "normal:", normal


def on_open(ws):
    print('OPEN')
    ws.send('{\"background\": true}')

host = 'localhost'
port = '6437'

if len(sys.argv) > 1:
    host = sys.argv[1]

if len(sys.argv) > 2:
    port = sys.argv[2]

url = 'ws://' + host + ':' + port + '/v6.json'

ws = websocket.WebSocketApp(url, on_message=on_message)
ws.on_open = on_open

ws.run_forever()
