module.exports = function (t, parameters) {
	var query = 'INSERT INTO address(name, company, street, street_2, city, state, zip, country, phone, type)\
				 VALUES(${name}, ${company}, ${street}, ${street_2}, ${city}, ${state}, ${zip}, ${country}, ${phone}, ${type})\
				 RETURNING id';

	return t.one(query, {
		name: parameters['name'],
		company: parameters['company'],
		street: parameters['street'],
		street_2: parameters['street_2'],
		city: parameters['city'],
		state: parameters['state'],
		zip: parameters['zip'],
		country: parameters['country'],
		phone: parameters['phone'],
		type: parameters['type']
	});
};