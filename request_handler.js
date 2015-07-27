module.exports = function (method, url, headers, request_body) {
	var response_body = JSON.strinigfy({ hello: 'world' });

	return Promise.resolve({
		status: 200,
		headers: {
			'Content-Type': 'application/json',
			'Content-Length': Buffer.byteLength(response_body)
		},
		body: response_body
	});
};