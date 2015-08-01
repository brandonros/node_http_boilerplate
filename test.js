var uuid = require('uuid');

var database = require('./database');

var register = require('./routes/register');
var login = require('./routes/login');
var store = require('./routes/store');
var carrier_account = require('./routes/carrier_account');
var store_carrier_account = require('./routes/store_carrier_account');

register(database.generate_db_connection(), {}, {
	name: 'b',
	company: null,
	street: '555 lakeview dr',
	street_2: null,
	city: 'coral springs',
	state: 'fl',
	zip: '33065',
	country: 'us',
	phone: '9119119111',
	email: 'a@aol.com',
	level: 1,
	password: '123456',
	type: 'commercial',
	seed: uuid.v4()
})
.then(function (res) {
	console.log(res);
})
.catch(function (err) {
	console.log(err.stack);
});

/*login({}, {
	email: 'a@aol.com',
	password: '123456',
	new_seed: uuid.v4()
})
.then(function (res) {
	console.log(res);
})
.catch(function (err) {
	console.log(err.stack);
});*/