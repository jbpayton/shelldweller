#!/usr/bin/env python3
"""In-memory REST API: CRUD /items, JSON, correct status codes, /health."""
import json
import re
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PORT = int(__import__('os').environ.get('API_PORT', '8081'))
store = {}                       # id -> item dict
counter = [0]                    # mutable box for the next id
lock = threading.Lock()
ID_RE = re.compile(r'^/items/(\d+)$')


def _reply(handler, code, payload):
    body = json.dumps(payload).encode()
    handler.send_response(code)
    handler.send_header('Content-Type', 'application/json')
    handler.send_header('Content-Length', str(len(body)))
    handler.end_headers()
    handler.wfile.write(body)


class Handler(BaseHTTPRequestHandler):
    def _path(self):
        return self.path.split('?', 1)[0].rstrip('/') or '/'

    def log_message(self, fmt, *args):   # keep stdout clean; traceback still to stderr
        pass

    def _read_json(self):
        length = int(self.headers.get('Content-Length') or 0)
        if length <= 0:
            return None
        raw = self.rfile.read(length)
        try:
            return json.loads(raw.decode() or 'null')
        except Exception:
            raise ValueError('invalid JSON')

    def do_GET(self):
        p = self._path()
        if p in ('/', '/health'):
            with lock:
                _reply(self, 200, {'ok': True, 'count': len(store)})
            return
        if p == '/items':
            with lock:
                items = sorted(store.values(), key=lambda i: i['id'])
            _reply(self, 200, {'items': items})
            return
        m = ID_RE.match(p)
        if m:
            iid = int(m.group(1))
            with lock:
                item = store.get(iid)
            if item is None:
                _reply(self, 404, {'error': 'not found'})
            else:
                _reply(self, 200, item)
            return
        _reply(self, 404, {'error': 'not found'})

    def do_POST(self):
        p = self._path()
        if p != '/items':
            _reply(self, 404, {'error': 'not found'})
            return
        try:
            data = self._read_json()
        except ValueError:
            _reply(self, 400, {'error': 'invalid JSON'})
            return
        if not isinstance(data, dict):
            _reply(self, 400, {'error': 'body must be a JSON object'})
            return
        with lock:
            counter[0] += 1
            item = dict(data)
            item['id'] = counter[0]
            store[counter[0]] = item
        _reply(self, 201, item)

    def do_PUT(self):
        m = ID_RE.match(self._path())
        if not m:
            _reply(self, 404, {'error': 'not found'})
            return
        iid = int(m.group(1))
        try:
            data = self._read_json()
        except ValueError:
            _reply(self, 400, {'error': 'invalid JSON'})
            return
        if not isinstance(data, dict):
            _reply(self, 400, {'error': 'body must be a JSON object'})
            return
        with lock:
            if iid not in store:
                _reply(self, 404, {'error': 'not found'})
                return
            merged = dict(store[iid])
            merged.update(data)
            merged['id'] = iid
            store[iid] = merged
        _reply(self, 200, merged)

    def do_DELETE(self):
        m = ID_RE.match(self._path())
        if not m:
            _reply(self, 404, {'error': 'not found'})
            return
        iid = int(m.group(1))
        with lock:
            if iid not in store:
                _reply(self, 404, {'error': 'not found'})
                return
            item = store.pop(iid)
        _reply(self, 200, {'deleted': item['id']})


def main():
    server = ThreadingHTTPServer(('0.0.0.0', PORT), Handler)
    print(f'api server listening on :{PORT}', flush=True)
    server.serve_forever()


if __name__ == '__main__':
    main()
