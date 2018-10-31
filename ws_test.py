import sys

if sys.version_info[0] > 2:
    raise Exception("Only python 2 currently")


from websocket import create_connection

host = 'localhost'
port = '6437'

if len(sys.argv) > 1:
  host = sys.argv[1]

if len(sys.argv) > 2:
  port = sys.argv[2]

# open connection to web socket and enable continous sending of background info
url = 'ws://' + host + ':' + port + '/v6.json'
ws = create_connection(url)
ws.send('{\"background\": true}')

version_info = ""
config_info = ""
first_data = ""

'''
Attempt to receive three packets. First and second are always received,
third only if Leap is sending data.
If no third packet is received within 0.2 seconds a timeout exception is triggered,
ending the script execution with code "0"
'''
ws.settimeout(0.2)
try:
	version_info = ws.recv()
	config_info = ws.recv()
	first_data = ws.recv()
except Exception:
	ws.close()
	sys.exit(0)

ws.close()

# Test if third packet starts with expected values
if str(first_data)[:19] != "{\"currentFrameRate\"":
		sys.exit(0)

# All seems in order.
sys.exit(1)