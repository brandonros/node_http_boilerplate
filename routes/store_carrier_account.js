var database = require('../database');

module.exports = function (t, headers, parameters) {
	var query = 'INSERT INTO store_carrier_account(store_id, carrier_account_id)\
				 VALUES(${store_id}, ${carrier_account_id})';

	return t.none(query, {
		store_id: parameters['store_id'],
		carrier_account_id: parameters['carrier_account_id']
	});
};