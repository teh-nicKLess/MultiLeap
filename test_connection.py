#!/usr/bin/python

import sys

if sys.version_info[0] > 2:
    raise Exception("Only python 2 currently")

import websocket

def on_message(ws, message):
  print(message)

def on_open(ws):
  print('OPEN')
  ws.send('{\"background\": true}')
#  ws.send('{\"enableGestures\": true}')

host = 'localhost'
port = '6437'

if len(sys.argv) > 1:
  host = sys.argv[1]

if len(sys.argv) > 2:
  port = sys.argv[2]

url = 'ws://' + host + ':' + port + '/v6.json'

ws = websocket.WebSocketApp(url, on_message = on_message)
ws.on_open = on_open

ws.run_forever()

