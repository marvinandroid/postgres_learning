START TRANSACTION;

create domain if not exist seat_t as char(3)
	check(VALUE ~ '^\d{2}\w$');

create table aircrafts(
	code short_code not null primary key,
	model norm_text not null,
	range integer not null
);

create table seats(
	seat_no seat_t not null,
	fare short_code not null references fares(code),
	aircraft short_code not null references aircrafts(code),
	constraint seats_pk primary key (aircraft, seat_no)
);

alter table flights
	add column aircraft short_code not null;

alter table flights
	add constraint flights_aircrafts_fk
		foreign key (aircraft)
		references aircrafts(code);

update tech.version set
	cur_version = 3,
	applied = current_timestamp;

ROLLBACK TRANSACTION;
-- COMMIT 