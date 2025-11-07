#!/usr/bin/env python3
import http.server
import socketserver
import os

# Change to the web build directory
os.chdir('build/web')

PORT = 8096

Handler = http.server.SimpleHTTPRequestHandler

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Server running at http://localhost:{PORT}")
    httpd.serve_forever()
