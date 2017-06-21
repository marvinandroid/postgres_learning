START TRANSACTION;

create domain air_code as char(3)
	check(VALUE !~ '\s');

create domain normalized_text as text
	check(VALUE != '' and VALUE !~ '^\s' and VALUE !~ '\s$' and VALUE !~ '\s{2}');

create table airports(
	airport_code air_code not null primary key,
	airport_name normalized_text not null,
	city normalized_text,
	timezone text,
	location geometry(POINT, 4326)
);

alter table flights
	add column destination_airport air_code not null;

alter table flights
	add constraint flights_destination_fk
		foreign key (destination_airport)
		references airports(airport_code);

alter table flights
	add column departure_airport air_code not null;

alter table flights
	add constraint flights_departure_fk
		foreign key (departure_airport)
		references airports(airport_code);

update tech.version set
	cur_version = 2,
	applied = current_timestamp;

-- ROLLBACK TRANSACTION;
COMMIT TRANSACTION;