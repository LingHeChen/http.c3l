module http;
import std::collections::list;
import std::net::tcp;
import std::io;
import std::core::mem;
import std::core::dstring;
def RequestHandler = fn Response (Request req);

struct Server {
    int port;
    String host;
    tcp::TcpServerSocket* server;
    list::List(<RequestHandler>) handlers;
}

fn Server* new(String host, int port) {
    Server* server = mem::new(Server);
    tcp::TcpServerSocket! tcp_server = tcp::listen(host, port, 10);
    if (try tcp_server)
    {
        server.server = &tcp_server;
        server.port = port;
        server.host = host;
        server.handlers.new_init();
        return server;
    }
    // io::printfn("Failed to listen on port %d: %s", port, err);

    return server;
}

macro Server.@handle(&server, String path = "/"; @body(req, resp)) {
    tcp::TcpSocket! s = tcp::accept(server.server);
    defer {
        s.close()!!;
    }
    if (catch err = s)
    {
        io::printfn("Failed to accept client: %s", err);
        return;
    }
    DString reqs = dstring::new();
    while (!(reqs.tcopy_str().contains("\r\n\r\n"))) {
        if (try new_char = s.read_byte()) {
            // io::printn(new_char);
            reqs.append_char(new_char);
        }
    }
    String req_str = reqs.tcopy_str();
    Request* req = parse_request(req_str);
    DString body_reqs = dstring::new();
    if (req.content_length > 0) {
        while (body_reqs.len() < req.content_length) {
            if (try new_char = s.read_byte()) {
                body_reqs.append_char(new_char);
            }
        }
        req.body = body_reqs.copy_str();
    }

    // char[1024] req;
    // usz! len = info.read(&req);
    // io::printfn("Request: %s", req.to_string());
    if (!req_str.contains("HTTP")) {
        return;
    }
    Response* resp = mem::new(Response);
    @body(req, resp);
    // io::printfn("Response: %s", resp.generate_text());
    (void)s.write(resp.generate_text());
}
