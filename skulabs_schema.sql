create table if not exists address(
	id serial primary key,
	name text not null,
	company text null,
	street text not null,
	street_2 text null,
	city text not null,
	state text null,
	zip text not null,
	country text not null,
	phone text null,
	type text not null
);

create table if not exists payment_method(
	id serial primary key,
	expire_year text not null,
	expire_month text not null,
	card_number text not null,
	card_type text not null,
	paypal_credit_card_id text not null
);

create table if not exists account(
	id serial primary key,
	created timestamp not null default now(),
	state text not null default 'wizard',
	label_printer text null,
	paper_printer text null,
	billing_plan text not null default 'free',
	billing_address_id int null,
	payment_method_id int null,
	wizard_stash json null,
	shipping_label_format text not null default 'zebra',
	batch_number int not null default 1000,
	billing_invoice_number int not null default 1000,
	purchase_order_number int not null default 1000,
	shipping_upcharge decimal(4) not null default 0.135,

	constraint billing_address_fkey foreign key (billing_address_id) references address(id),
	constraint payment_method_fkey foreign key (payment_method_id) references payment_method(id)
);

create table if not exists account_user(
	id serial primary key,
	account_id int not null,
	email text not null,
	name text not null,
	level int not null,
	avatar text not null default 'default_avatar.jpg',
	password text not null,
	active boolean not null default true,
	invite_hash text null,
	reset_hash text null,
	seed int not null,
	label_printer text null,
	paper_printer text null,
	filters_stash text null,
	columns_stash text null,
	tips_stash text null,
	batch_settings_stash text null,

	constraint account_fkey foreign key (account_id) references account(id)
);

create unique index email_idx on account_user(email);
create unique index user_name_idx on account_user(account_id, name);

create table if not exists carrier_account(
	id serial primary key,
	account_id int not null,
	name text not null,
	type text not null,
	account_number text not null,
	parameters_stash text null,

	constraint account_fkey foreign key (account_id) references account(id)	
);

create unique index carrier_account_name_idx on carrier_account(account_id, name);
create unique index carrier_account_number_idx on carrier_account(account_id, type, account_number);

create table if not exists store(
	id serial primary key,
	account_id int not null,
	name text not null,
	type text not null,
	logo text not null default 'default_store_logo.png',
	created timestamp not null default now(),
	identifier text not null,
	credentials_stash text not null,
	mark_shipped_flag text not null default 'always',
	origin_address_id int not null,
	return_address_id int not null,
	shipping_settings text not null,
	last_catalog_refresh timestamp null,
	last_order_refresh timestamp null,
	packing_slip_logo boolean not null default true,
	packing_slip_footer text null,

	constraint account_fkey foreign key (account_id) references account(id),
	constraint origin_address_fkey foreign key (origin_address_id) references address(id),
	constraint return_address_fkey foreign key (return_address_id) references address(id)	
);

create unique index store_name_idx on store(account_id, name);
create unique index store_identifier_idx on store(identifier);

create table if not exists store_carrier_account(
	store_id int not null,
	carrier_account_id int not null,

	constraint store_fkey foreign key (store_id) references store(id),
	constraint carrier_account_fkey foreign key (carrier_account_id) references carrier_account(id)
);

create unique index store_carrier_account_id on store_carrier_account(store_id, carrier_account_id);

create table if not exists shipping_service_link(
	id serial primary key,
	store_id int not null,
	cart_string text not null,
	carrier text not null,
	service text not null,

	constraint store_fkey foreign key (store_id) references store(id)
);

create unique index shipping_service_link_idx on shipping_service_link(store_id, cart_string);

create table if not exists order_packaging(
	id serial primary key,
	account_id int not null,
	hash text not null,
	packaging_stash text not null,

	constraint account_fkey foreign key (account_id) references account(id)
);

create unique index order_packaging_idx on order_packaging(account_id, hash);

create table if not exists barcode(
	id serial primary key,
	account_id int not null,
	barcode text not null,
	identifier text not null,
	zone text null,
	nickname text null,
	fulfillable int null,
	inbound int null,
	alert int null,
	cost money null,

	constraint account_fkey foreign key (account_id) references account(id)
);

create unique index barcode_idx on barcode(account_id, barcode);
create unique index identifier_idx on barcode(account_id, identifier);

create table if not exists item(
	id serial primary key,
	store_id int not null,
	integration_item_id text not null,
	integration_variant_id text not null,
	length decimal(2) null,
	width decimal(2) null,
	height decimal(2) null,
	ounces decimal(2) null,
	dropshipping_flag text null,

	constraint store_fkey foreign key (store_id) references store(id)
);

create unique index store_item_idx on item(store_id, integration_item_id, integration_variant_id);

create table if not exists item_pick_barcode(
	item_id int not null,
	barcode_id int not null,
	quantity int not null,

	constraint item_fkey foreign key (item_id) references item(id),
	constraint barcode_fkey foreign key (barcode_id) references barcode(id)
);

create unique index pick_barcode_idx on item_pick_barcode(item_id, barcode_id);

create table if not exists item_inventory_barcode(
	item_id int not null,
	barcode_id int not null,
	quantity int not null,

	constraint item_fkey foreign key (item_id) references item(id),
	constraint barcode_fkey foreign key (barcode_id) references barcode(id)
);

create unique index inventory_barcode_idx on item_inventory_barcode(item_id, barcode_id);

create table if not exists item_dropshipping_state(
	item_id int not null,
	state text not null,

	constraint item_fkey foreign key (item_id) references item(id)
);

create unique index item_dropshipping_idx on item_dropshipping_state(item_id, state);

create table if not exists item_restriction_state(
	item_id int not null,
	state text not null,

	constraint item_fkey foreign key (item_id) references item(id)
);

create unique index item_restriction_state_idx on item_restriction_state(item_id, state);

create table if not exists item_restriction_service(
	item_id int not null,
	carrier text not null,
	service text not null,

	constraint item_fkey foreign key (item_id) references item(id)
);

create unique index item_restriction_service_idx on item_restriction_service(item_id, carrier, service);

create table if not exists distributor(
	id serial primary key,
	account_id int not null,
	name text not null,
	email text not null,
	address_id int not null,

	constraint account_fkey foreign key (account_id) references account(id),
	constraint address_fkey foreign key (address_id) references address(id)
);

create unique index distributor_idx on distributor(account_id, name);

create table if not exists item_distributor(
	item_id int not null,
	distributor_id int not null,

	constraint item_fkey foreign key (item_id) references item(id),
	constraint distributor_fkey foreign key (distributor_id) references distributor(id)
);

create unique index item_distributor_dx on item_distributor(item_id, distributor_id);

create table if not exists purchase_order(
	id serial primary key,
	account_id int not null,
	distributor_id int not null,
	creator_id int not null,
	po_number text not null,
	status text not null,
	total decimal(2) not null,
	memo text null,

	constraint account_fkey foreign key (account_id) references account(id),
	constraint distributor_fkey foreign key (distributor_id) references distributor(id),
	constraint creator_fkey foreign key (creator_id) references account_user(id)
);

create unique index purchase_order_idx on purchase_order(account_id, po_number);

create table if not exists purchase_order_history(
	purchase_order_id int not null,
	user_id int not null,
	action text not null,
	time timestamp not null,

	constraint purchase_order_fkey foreign key (purchase_order_id) references purchase_order(id),
	constraint user_fkey foreign key (user_id) references account_user(id)
);

create table if not exists purchase_order_item(
	purchase_order_id int not null,
	item_id int not null,
	ordered int not null,
	received int not null,

	constraint purchase_order_fkey foreign key (purchase_order_id) references purchase_order(id),
	constraint item_fkey foreign key (item_id) references item(id)
);

create unique index purchase_order_item_idx on purchase_order_item(purchase_order_id, item_id);

create table if not exists box(
	id serial primary key,
	account_id int not null,
	length decimal(2) not null,
	width decimal(2) not null,
	height decimal(2) not null,
	name text not null,
	location text not null,

	constraint account_fkey foreign key (account_id) references account(id)
);

create unique index box_dimensions_idx on box(account_id, length, width, height);
create unique index box_name_idx on box(account_id, name);

create table if not exists billing_invoice(
	id serial primary key,
	account_id int not null,
	invoice_number text not null,
	time timestamp not null,
	amount money not null,
	url text not null,

	constraint account_fkey foreign key (account_id) references account(id)	
);

create unique index billing_invoice_idx on billing_invoice(account_id, invoice_number);

create table if not exists billing_invoice_item(
	invoice_id int not null,
	description text not null,
	amount money not null,

	constraint invoice_fkey foreign key (invoice_id) references billing_invoice(id)
);

create table if not exists store_order (
	id serial primary key,
	store_id int not null,
	order_number text not null,
	address_id int not null,
	total money not null,
	shipping_method text not null,
	packaging_hash text not null,
	status text not null,
	time timestamp not null,
	owner_id int null,
	exclude_analytics boolean null,

	constraint store_fkey foreign key (store_id) references store(id),
	constraint address_fkey foreign key (address_id) references address(id),
	constraint owner_fkey foreign key (owner_id) references account_user(id)
);

create unique index store_order_idx on store_order(store_id, order_number);

create table if not exists order_item(
	order_id int not null,
	item_id int not null,
	quantity int not null,
	dropshipped boolean not null,

	constraint order_fkey foreign key (order_id) references store_order(id),
	constraint item_fkey foreign key (item_id) references item(id)
);

create unique index order_item_idx on order_item(order_id, item_id);

create table if not exists order_scan(
	order_id int not null,
	user_id int not null,
	item_id int not null,
	barcode_id int not null,
	time timestamp not null,
	skip boolean not null,

	constraint order_fkey foreign key (order_id) references store_order(id),
	constraint item_fkey foreign key (item_id) references item(id),
	constraint user_fkey foreign key (user_id) references account_user(id),
	constraint barcode_fkey foreign key (barcode_id) references barcode(id)
);

create table if not exists order_misscan(
	order_id int not null,
	user_id int not null,
	value text not null,
	time timestamp not null,

	constraint order_fkey foreign key (order_id) references store_order(id),
	constraint user_fkey foreign key (user_id) references account_user(id)
);

create table if not exists order_item_clear(
	order_id int not null,
	user_id int not null,
	item_id int not null,
	time timestamp not null,
	skip boolean not null,

	constraint order_fkey foreign key (order_id) references store_order(id),
	constraint item_fkey foreign key (item_id) references item(id),
	constraint user_fkey foreign key (user_id) references account_user(id)
);

create table if not exists order_history(
	order_id int not null,
	user_id int not null,
	action text not null,
	time timestamp not null,

	constraint order_fkey foreign key (order_id) references store_order(id),
	constraint user_fkey foreign key (user_id) references account_user(id)
);

create table if not exists shipment(
	id serial primary key,
	creator_id int not null,
	from_address_id int not null,
	to_address_id int not null,
	order_id int not null,
	service text not null,
	carrier text not null,
	length decimal(2) not null,
	width decimal(2) not null,
	height decimal(2) not null,
	ounces int not null,
	tracking_number text not null,
	rate money not null,
	label_url text not null,
	insurance money null,
	signature boolean null,
	time timestamp not null,
	voided boolean not null,

	constraint creator_fkey foreign key (creator_id) references account_user(id),
	constraint from_fkey foreign key (from_address_id) references address(id),
	constraint to_fkey foreign key (to_address_id) references address(id),
	constraint order_fkey foreign key (order_id) references store_order(id)
);

create unique index shipment_idx on shipment(tracking_number);

create table if not exists batch(
	id serial primary key not null,
	account_id int not null,
	batch_number text not null,
	status text not null,
	state text not null,
	owner_id int not null,
	exclude_analytics boolean not null,

	constraint account_fkey foreign key (account_id) references account(id),
	constraint owner_fkey foreign key (owner_id) references account_user(id)
);

create unique index batch_idx on batch(account_id, batch_number);

create table if not exists batch_order(
	batch_id int not null,
	order_id int not null,
	bin_number int not null,

	constraint batch_fkey foreign key (batch_id) references batch(id),
	constraint order_fkey foreign key (order_id) references store_order(id)
);

create unique index batch_order_idx on batch_order(batch_id, order_id);

create table if not exists batch_history(
	batch_id int not null,
	user_id int not null,
	action text not null,
	time timestamp not null,

	constraint batch_fkey foreign key (batch_id) references batch(id),
	constraint user_fkey foreign key (user_id) references account_user(id)
);

create table if not exists batch_break(
	batch_id int not null,
	user_id int not null,
	pause_time timestamp not null,
	resume_time timestamp null,

	constraint batch_fkey foreign key (batch_id) references batch(id),
	constraint user_fkey foreign key (user_id) references account_user(id)
);

create table if not exists amazon_fulfillment_deduction(
	store_id int not null,
	amazon_shipment_id text not null,
	creator_id int not null,
	time timestamp not null,

	constraint creator_fkey foreign key (creator_id) references account_user(id),
	constraint store_fkey foreign key (store_id) references store(id)
);

create unique index amazon_fulfillment_deduction_idx on amazon_fulfillment_deduction(store_id, amazon_shipment_id);

create table if not exists combined_order(
	id serial primary key,
	account_id int not null,

	constraint account_fkey foreign key (account_id) references account(id)
);

create table if not exists combined_order_map(
	combined_order_id int not null,
	order_id int not null,

	constraint combined_order_fkey foreign key (combined_order_id) references combined_order(id),
	constraint order_fkey foreign key (order_id) references store_order(id)
);

create unique index combined_order_map_idx on combined_order_map(combined_order_id, order_id);