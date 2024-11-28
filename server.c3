module http;
import std::collections::list;
import std::net::tcp;
import std::io;
import std::core::mem;
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
    list::List(<char>) reqs;
    reqs.new_init();
    while (!((String)reqs.to_tarray()).contains("\r\n\r\n")) {
        if (try new_char = s.read_byte()) {
            // io::printn(new_char);
            reqs.push(new_char);
        }
    }
    String req_str = (String)reqs.to_tarray();
    Request* req = parse_request(req_str);
    list::List(<char>) body_reqs;
    body_reqs.new_init();
    if (req.content_length > 0) {
        while (body_reqs.len() < req.content_length) {
            if (try new_char = s.read_byte()) {
                body_reqs.push(new_char);
            }
        }
        req.body = (String)body_reqs.to_tarray();
        body_reqs.free();
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
