var routes_map = {
	'/register': require('./routes/register'),
	'/login': require('./routes/login')
};

module.exports = function (method, url, headers, body) {
	return function (headers, parameters) {
		var db = database.generate_db_connection();

		return db.tx(function () {
			var t = this;

			return routes_map[route](t, headers, body);
		});
	};
};