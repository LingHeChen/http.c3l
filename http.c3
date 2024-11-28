module http;
import std::io;
import std::net::tcp;
import std::thread;
import std::collections::map;
import std::collections::list;
import std::core::string;

enum HttpStatus : int (int code, String description)
{
    OK = {200, "OK"},
    CREATED = {201, "Created"},
    ACCEPTED = {202, "Accepted"},
    NO_CONTENT = {204, "No Content"},
    MOVED_PERMANENTLY = {301, "Moved Permanently"},
    FOUND = {302, "Found"},
    SEE_OTHER = {303, "See Other"},
    NOT_MODIFIED = {304, "Not Modified"},
    USE_PROXY = {305, "Use Proxy"},
    TEMPORARY_REDIRECT = {307, "Temporary Redirect"},
    PERMANENT_REDIRECT = {308, "Permanent Redirect"},
    BAD_REQUEST = {400, "Bad Request"},
    UNAUTHORIZED = {401, "Unauthorized"},
    FORBIDDEN = {403, "Forbidden"},
    NOT_FOUND = {404, "Not Found"},
    METHOD_NOT_ALLOWED = {405, "Method Not Allowed"},
    NOT_ACCEPTABLE = {406, "Not Acceptable"},
    PROXY_AUTHENTICATION_REQUIRED = {407, "Proxy Authentication Required"},
    REQUEST_TIMEOUT = {408, "Request Timeout"},
    CONFLICT = {409, "Conflict"},
    GONE = {410, "Gone"},
    LENGTH_REQUIRED = {411, "Length Required"},
    PRECONDITION_FAILED = {412, "Precondition Failed"},
    PAYLOAD_TOO_LARGE = {413, "Payload Too Large"},
    URI_TOO_LONG = {414, "URI Too Long"},
    UNSUPPORTED_MEDIA_TYPE = {415, "Unsupported Media Type"},
    RANGE_NOT_SATISFIABLE = {416, "Range Not Satisfiable"},
    EXPECTATION_FAILED = {417, "Expectation Failed"},
    IM_A_TEAPOT = {418, "I'm a teapot"},
    MISDIRECTED_REQUEST = {421, "Misdirected Request"},
    UNPROCESSABLE_ENTITY = {422, "Unprocessable Entity"},
    LOCKED = {423, "Locked"},
    FAILED_DEPENDENCY = {424, "Failed Dependency"},
    TOO_EARLY = {425, "Too Early"},
    UPGRADE_REQUIRED = {426, "Upgrade Required"},
    PRECONDITION_REQUIRED = {428, "Precondition Required"},
    TOO_MANY_REQUESTS = {429, "Too Many Requests"},
    REQUEST_HEADER_FIELDS_TOO_LARGE = {431, "Request Header Fields Too Large"},
    UNAVAILABLE_FOR_LEGAL_REASONS = {451, "Unavailable For Legal Reasons"},
    INTERNAL_SERVER_ERROR = {500, "Internal Server Error"},
    NOT_IMPLEMENTED = {501, "Not Implemented"},
    BAD_GATEWAY = {502, "Bad Gateway"},
    SERVICE_UNAVAILABLE = {503, "Service Unavailable"},
    GATEWAY_TIMEOUT = {504, "Gateway Timeout"},
    HTTP_VERSION_NOT_SUPPORTED = {505, "HTTP Version Not Supported"},
    VARIANT_ALSO_NEGOTIATES = {506, "Variant Also Negotiates"},
    INSUFFICIENT_STORAGE = {507, "Insufficient Storage"},
    LOOP_DETECTED = {508, "Loop Detected"},
    NOT_EXTENDED = {510, "Not Extended"},
    NETWORK_AUTHENTICATION_REQUIRED = {511, "Network Authentication Required"}
}

enum ContentType : int (String description)
{
    // 文本类 (Text)
    TEXT_PLAIN = "text/plain",                   // 纯文本
    TEXT_HTML = "text/html",                     // HTML 文档
    TEXT_CSS = "text/css",                       // CSS 样式表
    TEXT_JAVASCRIPT = "text/javascript",         // JavaScript 脚本
    TEXT_CSV = "text/csv",                       // CSV 格式
    TEXT_XML = "text/xml",                       // XML 文档
    TEXT_MARKDOWN = "text/markdown",             // Markdown 文档

    // 应用程序类 (Application)
    APPLICATION_JSON = "application/json",       // JSON 数据
    APPLICATION_XML = "application/xml",         // XML 数据
    APPLICATION_FORM_URLENCODED = "application/x-www-form-urlencoded",  // 表单数据
    MULTIPART_FORM_DATA = "multipart/form-data",// 表单数据（包含文件）
    APPLICATION_OCTET_STREAM = "application/octet-stream", // 二进制数据
    APPLICATION_PDF = "application/pdf",        // PDF 文档
    APPLICATION_ZIP = "application/zip",        // ZIP 文件
    APPLICATION_GZIP = "application/gzip",      // GZIP 文件
    APPLICATION_LD_JSON = "application/ld+json",// JSON-LD
    APPLICATION_MSWORD = "application/msword",  // Word 文档
    APPLICATION_EXCEL = "application/vnd.ms-excel", // Excel 文件
    APPLICATION_POWERPOINT = "application/vnd.ms-powerpoint", // PowerPoint 文件

    // 图像类 (Image)
    IMAGE_PNG = "image/png",                    // PNG 图片
    IMAGE_JPEG = "image/jpeg",                  // JPEG 图片
    IMAGE_GIF = "image/gif",                    // GIF 图片
    IMAGE_SVG = "image/svg+xml",                // SVG 图片
    IMAGE_WEBP = "image/webp",                  // WebP 图片
    IMAGE_BMP = "image/bmp",                    // BMP 图片
    IMAGE_TIFF = "image/tiff",                  // TIFF 图片
    IMAGE_ICO = "image/vnd.microsoft.icon",     // ICO 图标

    // 音频类 (Audio)
    AUDIO_MPEG = "audio/mpeg",                  // MP3 音频
    AUDIO_WAV = "audio/wav",                    // WAV 音频
    AUDIO_OGG = "audio/ogg",                    // Ogg 音频
    AUDIO_WEBM = "audio/webm",                  // WebM 音频
    AUDIO_AAC = "audio/aac",                    // AAC 音频
    AUDIO_FLAC = "audio/flac",                  // FLAC 音频

    // 视频类 (Video)
    VIDEO_MP4 = "video/mp4",                    // MP4 视频
    VIDEO_MPEG = "video/mpeg",                  // MPEG 视频
    VIDEO_OGG = "video/ogg",                    // Ogg 视频
    VIDEO_WEBM = "video/webm",                  // WebM 视频
    VIDEO_AVI = "video/x-msvideo",              // AVI 视频
    VIDEO_3GPP = "video/3gpp",                  // 3GPP 视频
    VIDEO_QUICKTIME = "video/quicktime",        // QuickTime 视频

    // 字体类 (Font)
    FONT_OTF = "font/otf",                      // OpenType 字体
    FONT_TTF = "font/ttf",                      // TrueType 字体
    FONT_WOFF = "font/woff",                    // Web Open Font Format
    FONT_WOFF2 = "font/woff2",                  // Web Open Font Format 2

    // 其他类 (Other)
    APPLICATION_TAR = "application/x-tar",      // TAR 文件
    APPLICATION_7Z = "application/x-7z-compressed", // 7z 文件
    APPLICATION_RAR = "application/x-rar-compressed", // RAR 文件
    APPLICATION_BZIP = "application/x-bzip",    // Bzip 文件
    APPLICATION_BZIP2 = "application/x-bzip2",  // Bzip2 文件
    APPLICATION_JAVA_ARCHIVE = "application/x-java-archive" // Java Archive 文件
}

macro @from_string($Type, String s) {
    foreach ($Type ev : $Type.values) {
        if (ev.description == s) {
            return ev;
        }
    }
    io::printfn("Unknown content type: %s", s);
    return $Type.TEXT_PLAIN;
}

enum HttpVersion :int (String text)
{
    V0_9 = "0.9",
    V1_0 = "1.0",
    V1_1 = "1.1",
    V2 = "2",
    V3 = "3",
}

union JsonValue {
    double as_number;
    String as_str;
    bool as_bool;
    map::HashMap(<String, JsonValue>) as_obj;
    list::List(<JsonValue>) as_list;
}

struct Response{
    HttpVersion _version;
    ContentType _content_type;
    HttpStatus _status;
    map::HashMap(<String, String>)* _headers;
    String _body;
}

fn Response* Response.init(&self)
{
    self._version = HttpVersion.V1_1;
    self._content_type = ContentType.TEXT_PLAIN;
    self._status = HttpStatus.NOT_FOUND;
    self._headers = mem::new(map::HashMap(<String, String>));
    self._body = "";

    return self;
}

fn Response* Response.content_type(&self, ContentType c) {
    self._content_type = c;
    return self;
}

fn Response* Response.version(&self, HttpVersion v) {
    self._version = v;
    return self;
}

fn Response* Response.header(&self, String key, String val) {
    self._headers.set(key, val);
    return self;
}

fn Response* Response.status(&self, HttpStatus s)
{
    self._status = s;
    return self;
}

fn Response* Response.headers(&self, map::HashMap(<String, String>)* mapping) {
    self._headers = mapping;
    return self;
}

fn Response* Response.body(&self, String b) {
    self._body = b;
    return self;
}

fn String Response.parse_headers(&self)
{
    String raw_headers = "";
    self._headers.@each(; String key, String val) {
        raw_headers = string::new_format("%s\n%s: %s", raw_headers, key, val);
    };
    return raw_headers;
}

fn String Response.generate_text(&self) {
    String text = `HTTP/%s %d %s
Content-Type: %s
Content-Length: %d%s

%s`;
    String raw_headers = self.parse_headers();
    String response_text = string::new_format(text, self._version.text, self._status.code, self._status.description, self._content_type.description, self._body.len, raw_headers, self._body);
    return response_text;
}

fn String Response.from(&self, String raw_resp) {
    self._body = raw_resp;
    return self.generate_text();
}

// macro @json(#expr) {
//     io::printn(#expr);
// }

// macro @map(#expr) {
//     io::printn(#expr);
// }

struct Request {
    HttpVersion version;
    String method;
    String path;
    ContentType content_type;
    uint content_length;
    map::HashMap(<String, String>)* headers;
    map::HashMap(<String, String>)* query;
    String body;
}

fn void Request.init(&self) {
    self.version = HttpVersion.V1_1;
    self.method = "";
    self.path = "";
    self.content_type = ContentType.TEXT_PLAIN;
    self.content_length = 0;
    self.body = "";
    self.headers = mem::new(map::HashMap(<String, String>));
    self.query = mem::new(map::HashMap(<String, String>));
}

fn void Request._parse_path(&self, String path) {
    String[] parts = path.split("?");
    self.path = parts[0];
    if (parts.len > 1) {
        self.query = mem::new(map::HashMap(<String, String>));
        String[] query_parts = parts[1].split("&");
        foreach (String query_part : query_parts) {
            String[] query_pair = query_part.split("=");
            self.query.set(query_pair[0], query_pair[1]);
        }
    }
}

fn Request* parse_request(String raw_request) {
    Request* req = mem::new(Request);
    req.init();
    String[] lines = raw_request.split("\n");
    String[] parts = lines[0].trim().split(" ");
    switch (parts[0]) {
    case "GET":
        req.method = "GET";
        break;
    case "POST":
        req.method = "POST";
        break;
    case "PUT":
        req.method = "PUT";
        break;
    case "DELETE":
        req.method = "DELETE";
        break;
    case "PATCH":
        req.method = "PATCH";
        break;
    case "HEAD":
        req.method = "HEAD";
        break;
    case "CONNECT":
        req.method = "CONNECT";
        break;
    case "TRACE":
        req.method = "TRACE";
        break;
    case "OPTIONS":
        req.method = "OPTIONS";
        break;
    default:
        io::printfn("Unknown method: '%s'", parts[0]);
    }

    req._parse_path(parts[1]);

    switch (parts[2]) {
    case "HTTP/1.1":
        req.version = HttpVersion.V1_1;
        break;
    case "HTTP/1.0":
        req.version = HttpVersion.V1_0;
        break;
    case "HTTP/0.9":
        req.version = HttpVersion.V0_9;
        break;
    case "HTTP/2":
        req.version = HttpVersion.V2;
        break;
    case "HTTP/3":
        req.version = HttpVersion.V3;
        break;
    default:
        io::printfn(`Unknown HTTP version: "%s"`, parts[2]);
    }

    bool is_body = false;
    foreach (String line : lines[1..]) {
        line = line.trim();
        if (line.len == 0) {
            is_body = true;
            continue;
        }
        if (is_body) {
            req.body = line;
        } else {
            String[] kv = line.split(":");
            req.headers.set(kv[0], string::join_new(kv[1..], ":"));
            if (kv[0] == "Content-Length") {
                req.content_length = kv[1].to_uint()!!;
            }
            if (kv[0] == "Content-Type") {
                req.content_type = @from_string(ContentType, kv[1]);
            }
        }
    }
    return req;
}

fn String Request.to_string(&self) {
    // 构建基本请求行
    String result = string::new_format("%s %s HTTP/%s\n", 
        self.method, 
        self.path, 
        self.version.text
    );
    
    // 添加headers
    self.headers.@each(; String key, String value) {
        result = string::new_format("%s%s: %s\n", result, key, value);
    };
    
    // 添加空行分隔header和body
    result = string::new_format("%s\n", result);
    
    // 如果有body则添加
    if (self.body.len > 0) {
        result = string::new_format("%s%s", result, self.body);
    }
    
    // 如果有查询参数，添加查询参数信息（可选，用于调试）
    if (self.query.len() > 0) {
        result = string::new_format("%s\n\nQuery Parameters:\n", result);
        self.query.@each(; String key, String value) {
            result = string::new_format("%s%s: %s\n", result, key, value);
        };
    }
    
    return result;
}
