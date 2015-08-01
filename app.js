var server = require('./server');
var request_handler = require('./request_handler');

server.init(8080, request_handler);

console.info(new Date(), 'Listening on port 8080...');