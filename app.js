var http = require('http');

var request_handler = require('./request_handler');

function send_response(response, status, headers, body) {
	respone.writeHead(status, headers);

	response.write(body);

	response.end();
}

function handle_error(response, err) {
	console.error(new Date(), err.stack);

	var body = JSON.stringify({ err: err.stack });

	var headers = {
		'Content-Type': 'application/json',
		'Content-Length': Buffer.byteLength(body)
	};

	send_response(response, 500, headers, body);
}

function read_body(method, request) {
	if (method === 'GET') {
		return Promise.resolve();
	}

	return new Promise(function (resolve, reject) {
		var buf = '';

		request.on('data', function (chunk) {
			buf += chunk;
		});

		request.on('end', function () {
			resolve(buf);
		});

		request.on('error', function (err) {
			reject(err);
		})
	});
}

function request_wrapper(request, response) {
	var url = request['url'];
	var method = request['method'];
	var headers = request['headers'];

	read_body(method, request)
	.then(function (body) {
		return request_handler(method, url, headers, body);
	})
	.then(function (res) {
		send_response(response, res['status'], res['headers'], res['body']);
	})
	.catch(function (err) {
		handle_error(response, err);
	});
}

function init_server(port) {
	var srv = http.createServer();

	srv.on('request', request_wrapper);

	srv.listen(port);
}

init_server(8080);