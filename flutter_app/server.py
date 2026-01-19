import http.server
import socketserver
import os

# The port is set by Render, default to 8080 for local testing
PORT = int(os.environ.get("PORT", 8080))
# The directory where our Flutter build is located
DIRECTORY = "build/web"

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

print(f"Serving files from {DIRECTORY} on port {PORT}")
with socketserver.TCPServer(("", PORT), Handler) as httpd:
    httpd.serve_forever()
