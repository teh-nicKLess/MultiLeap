#!/usr/bin/python

import sys

if sys.version_info[0] > 2:
    raise Exception("Only python 2 currently")

import websocket

messageCounter = 0

def on_message(ws, message):
  print(message)
  sys.exit(1)
  '''
  print(messageCounter)
  print("x")
  
  messageCounter += 1
  
  if messageCounter > 9: sys.exit()'''
  
def on_error(ws, error):
	sys.exit(0)

def on_open(ws):
  print('OPEN')
  ws.send('{\"background\": true}')
  #ws.send('{\"enableGestures\": true}')

host = 'localhost'
port = '6437'


if len(sys.argv) > 1:
  host = sys.argv[1]

if len(sys.argv) > 2:
  port = sys.argv[2]

url = 'ws://' + host + ':' + port + '/v6.json'

ws = websocket.WebSocketApp(url, on_message = on_message, on_error = on_error)
ws.on_open = on_open

ws.run_forever()