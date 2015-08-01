var database = require('../database');

module.exports = function (t, headers, parameters) {
	var query = 'SELECT id, account_id, password\
				 FROM account_user\
				 WHERE email = ${email}';

	return t.one(query, {
		email: parameters['email']
	})
	.then(function (res) {
		if (!res) {
			throw new Error('E-mail not found');
		}

		if (res['password'] !== parameters['password']) {
			throw new Error('Invalid password');
		}

		var query = 'UPDATE account_user\
					 SET seed = ${new_seed}\
					 WHERE id = ${user_id}';

		return t.none(query, {
			user_id: res['user_id'],
			seed: parameters['new_seed']
		})
		.then(function () {
			return {
				account_id: res['account_id'],
				user_id: res['user_id']
			};
		});
	});
};