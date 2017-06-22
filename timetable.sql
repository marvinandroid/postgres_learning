START TRANSACTION;
set local search_path to "$user", bookings, public;

/*
with flights_tz as (
	select
		fl.flight_id f_id,
		fl.flight_no f_no,
		d_port.airport_name d_port_name,
		a_port.airport_name a_port_name,
		(fl.scheduled_departure at time zone d_port.timezone) depart_time
		from flights fl
		inner join airports d_port on fl.departure_airport = d_port.airport_code
		inner join airports a_port on fl.arrival_airport = a_port.airport_code
)
select count(fl.f_id) flight_count,
	fl.f_no flight_number,
	fl.d_port_name || ' - ' || fl.a_port_name direction,
	extract(isodow from fl.depart_time) s_wday,
	extract(hour from fl.depart_time) s_hour,
	extract(minute from fl.depart_time) s_minute
	from flights_tz fl
	group by flight_number, direction, s_wday, s_hour, s_minute
	order by flight_number;
*/

create view bookings.flight_timetable as
with flights_tz as (
	select
		fl.flight_id f_id,
		fl.flight_no f_no,
		d_port.airport_name d_port_name,
		a_port.airport_name a_port_name,
		(fl.scheduled_departure at time zone d_port.timezone) depart_time
		from bookings.flights fl
		inner join airports d_port on fl.departure_airport = d_port.airport_code
		inner join airports a_port on fl.arrival_airport = a_port.airport_code
)
select 
	count(fl.f_id) flight_count,
	fl.f_no flight_number,
	fl.d_port_name || ' - ' || fl.a_port_name direction,
	fl.d_port_name departure_airport,
	fl.a_port_name arrival_airport,
	to_char(fl.depart_time, 'Dy HH24:MI') f_time,
	extract(isodow from fl.depart_time)::integer s_dow, 
	make_time(extract(hour from fl.depart_time)::integer,
		extract(minute from fl.depart_time)::integer, 0) s_time
	from flights_tz fl
	group by flight_number, direction, departure_airport, 
	arrival_airport, f_time, s_dow, s_time;

COMMIT TRANSACTION;