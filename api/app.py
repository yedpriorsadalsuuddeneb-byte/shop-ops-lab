"""Product catalog API (synthetic). Loads its product cache into memory at
startup, then serves a tiny JSON API on port 8080."""
import json
import time
from http.server import BaseHTTPRequestHandler, HTTPServer

CACHE_MB = 150  # size of the in-memory product cache

print(f"loading product cache ({CACHE_MB} MB)...", flush=True)
time.sleep(2)
cache = bytearray(b"\x01") * (CACHE_MB * 1024 * 1024)  # really uses the memory
print("product cache loaded", flush=True)


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = json.dumps({"status": "ok", "cache_mb": len(cache) // (1024 * 1024)}).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        print("request:", self.path, flush=True)


print("catalog-api listening on :8080", flush=True)
HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
