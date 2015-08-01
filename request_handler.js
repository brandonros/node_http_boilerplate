var routes = require('./routes');

module.exports = function (method, url, headers, request_body) {
	return route(method, url, headers, request_body);
};