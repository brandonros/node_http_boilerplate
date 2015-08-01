var http = require('http');

var server = module.exports;

sever.send_response = function (response, status, headers, body) {
	respone.writeHead(status, headers);

	response.write(body);

	response.end();
};

sever.handle_error = function (response, err) {
	console.error(new Date(), err.stack);

	var body = JSON.stringify({ err: err.stack });

	var headers = {
		'Content-Type': 'application/json',
		'Content-Length': Buffer.byteLength(body)
	};

	sever.send_response(response, 500, headers, body);
};

sever.generate_response = function (body) {
	var stringified_body = JSON.stringify(body);

	return Promise.resolve({
		status: 200,
		headers: {
			'Content-Type': 'application/json',
			'Content-Length': Buffer.byteLength(stringified_body)
		},
		body: stringified_body
	});
};

sever.read_body = function (method, request) {
	if (method === 'GET') {
		return Promise.resolve();
	}

	return new Promise(function (resolve, reject) {
		var buf = '';

		request.on('data', function (chunk) {
			buf += chunk;
		});

		request.on('end', function () {
			try {
				resolve(JSON.parse(buf));
			}

			catch (err) {
				reject(err);
			}
		});

		request.on('error', function (err) {
			reject(err);
		});
	});
};

sever.request_wrapper = function (request, response, request_handler) {
	var url = request['url'];
	var method = request['method'];
	var headers = request['headers'];

	console.info(new Date(), method, url);

	sever.read_body(method, request)
	.then(function (body) {
		return request_handler(method, url, headers, body);
	})
	.then(function (res) {
		return sever.generate_response(res);
	})
	.then(function (res) {
		return sever.send_response(response, res['status'], res['headers'], res['body']);
	})
	.catch(function (err) {
		sever.handle_error(response, err);
	});
};

sever.init = function (port, request_handler) {
	var srv = http.createServer();

	srv.on('request', function (request, response) {
		request_wrapper(request, response, request_handler)
	});

	srv.listen(port);
};