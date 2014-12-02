
var http = require("http"), server,
    port = parseInt(process.env.PORT || 8888, 10);

server = http.createServer(function (request, response) {

    response.writeHead(200, {
        "Content-Type": "text/plain"
    });
    response.write("Hello there!");
    response.end();

}).listen(port);
