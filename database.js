var pgp = require('pg-promise')();

var database = module.exports;

database.generate_db_connection = function () {
	var cn = {
		host: 'localhost',
		port: 5432,
		database: 'brandonros1',
		user: 'brandonros1',
		password: ''
	};

	return pgp(cn);
};

database.query = function (db, query, values) {
	return db.query(query, values);
};