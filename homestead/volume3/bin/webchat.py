#!/usr/bin/env python3
"""dweller chat server: page on :8080. POST /say -> chat/inbox.txt, GET /reply <- chat/reply.txt"""
import datetime, pathlib, socketserver, http.server

HOME = pathlib.Path("/home/dweller")
INBOX = HOME / "chat" / "inbox.txt"
REPLY = HOME / "chat" / "reply.txt"
PAGE = HOME / "web" / "index.html"

class H(http.server.BaseHTTPRequestHandler):
    def _send(self, code, body, ctype="text/plain; charset=utf-8"):
        b = body.encode("utf-8", "replace")
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(b)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        try:
            self.wfile.write(b)
        except (BrokenPipeError, ConnectionResetError):
            pass

    def do_GET(self):
        p = self.path.split("?")[0]
        if p in ("/", "/index.html"):
            try:
                self._send(200, PAGE.read_text(), "text/html; charset=utf-8")
            except Exception as e:
                self._send(500, "page error: %r" % (e,))
        elif p == "/reply":
            try:
                self._send(200, REPLY.read_text())
            except FileNotFoundError:
                self._send(200, "no reply yet")
        elif p == "/ping":
            self._send(200, "pong")
        else:
            self._send(404, "not found")

    def do_POST(self):
        if self.path.split("?")[0] == "/say":
            n = int(self.headers.get("Content-Length") or 0)
            msg = self.rfile.read(min(n, 4000)).decode("utf-8", "replace").strip()
            if not msg:
                self._send(400, "empty"); return
            INBOX.parent.mkdir(parents=True, exist_ok=True)
            ts = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
            with open(INBOX, "a") as f:
                f.write("[%s] %s\n" % (ts, msg))
            self._send(200, "received — the dweller answers on its next turn (<=60s)")
        else:
            self._send(404, "not found")

    def log_message(self, *a):
        pass

socketserver.ThreadingTCPServer.allow_reuse_address = True
with socketserver.ThreadingTCPServer(("0.0.0.0", 8080), H) as srv:
    srv.serve_forever()
