from http.server import HTTPServer, SimpleHTTPRequestHandler

class CORSServer(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        super().end_headers()

# Escolha a porta
PORT = 8000
httpd = HTTPServer(('127.0.0.1', PORT), CORSServer)

print(f"Servidor rodando em http://127.0.0.1:{PORT}")
httpd.serve_forever()
