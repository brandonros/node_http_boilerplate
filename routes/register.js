var database = require('../database');

var insert_address = require('./address');

module.exports = function (t, headers, parameters) {
	return insert_address(t, parameters)
		.then(function (res) {
			var query = 'INSERT INTO account(billing_address_id)\
						 VALUES(${id})\
						 RETURNING id AS account_id';

			return t.one(query, { 
				id: res['address_id'] 
			});
		})
		.then(function (res) {
			var query = 'INSERT INTO account_user(account_id, email, name, level, password, seed)\
						 VALUES(${account_id}, ${email}, ${name}, ${level}, ${password}, ${seed})\
						 RETURNING id AS user_id, account_id AS account_id';

			return t.one(query, {
				account_id: res['account_id'],
				email: parameters['email'],
				name: parameters['name'],
				level: parameters['level'],
				password: parameters['password'],
				seed: parameters['seed']
			})
	});
};