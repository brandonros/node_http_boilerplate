var database = require('../database');

module.exports = function (t, headers, parameters) {
	var query = 'INSERT INTO carrier_account(account_id, name, type, account_number, parameters_stash)\
				 VALUES(${account_id}, ${name}, ${type}, ${account_number}, ${parameters_stash})\
				 RETURNING id AS carrier_account_id';

	return t.one(query, {
		account_id: parameters['account_id'],
		name: parameters['name'],
		type: parameters['type'],
		account_number: parameters['account_number'],
		parameters_stash: parameters['parameters_stash']
	});
};