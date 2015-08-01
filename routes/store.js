var database = require('../database');

var insert_address = require('./address');

module.exports = function (t, headers, parameters) {
	return Q.all([insert_address(t, parameters), insert_address(t, parameters)])
		.then(function (res) {
			var query = 'INSERT INTO store(account_id, name, type, identifier, credentials_stash, origin_address_id, return_address_id, shipping_settings)\
						 VALUES(${account_id}, ${name}, ${type}, ${identifier}, ${credentials_stash}, ${origin_address_id}, ${return_address_id}, ${shipping_settings})\
						 RETURNING id AS store_id';

			return t.one(query, {
				account_id: parameters['account_id'],
				name: parameters['name'],
				type: parameters['type'],
				identifier: parameters['identifier'],
				credentials_stash: parameters['credentials_stash'],
				origin_address_id: res[0]['address_id'],
				return_address_id: res[1]['address_id'],
				shipping_settings: parameters['shipping_settings']
			});
		});
};