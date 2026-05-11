from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import time

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/state":
            state = {
                "timestamp": time.time(),
                "status": "ONLINE",
                "rf_250ghz": "ANCHORED",
                "xyo_anchor": "STABLE",
                "continuity_hash": "ACTIVE"
            }
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(state).encode())
        else:
            self.send_response(404)
            self.end_headers()

server = HTTPServer(("0.0.0.0", 8000), Handler)
server.serve_forever()
