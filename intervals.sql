START TRANSACTION;
set local search_path to "$user", bookings, public;

with fl_dates as (
	select
		min(fl.scheduled_departure) begin_time,
		max(fl.scheduled_departure) end_time
		from flights fl
)
select
	extract(days from end_time - begin_time)::int - 
		(8 - extract(isodow from begin_time)::int) t_days,
	to_char(begin_time, 'Day') begin_dow,
	(begin_time + 
		(8 - extract(isodow from begin_time)::int)*interval '1 day')::date first_monday
	from fl_dates;

COMMIT TRANSACTION;