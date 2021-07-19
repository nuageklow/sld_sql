/*****

ZOOM WEBINAR TABLES 

*****/
/* zoom_webinar_event on test schema */
CREATE TABLE test.zoom_webinar_event (
	u_event_id text null,
	uuid text NULL,
	event_id text NOT NULL DEFAULT ''::text,
	event_name text,
	event_city text,
	event_country_region text,
	organising_chapter text,
	start_time timestamp NULL DEFAULT '2016-01-01 00:00:00'::timestamp without time zone,
	duration_minutes int4 NULL DEFAULT 1,
	event_status text NULL,
	CONSTRAINT zoom_webinar_event_pkey PRIMARY KEY (event_id)
);

/* zoom_webinar_registration on test schema */
CREATE TABLE test.zoom_webinar_registration (
	u_event_id text null,
	id text NOT NULL DEFAULT ''::text,
	email text NULL,
	first_name text NULL,
	last_name text NULL,
	gender text NULL,
	age_group text NULL,
	city text NULL,
	country_region text NULL,
	current_industry text NULL,
	current_job_level text NULL,
	current_comopany text NULL,
	latest_role text NULL,
	status text NULL,
	registration_timestamp timestamp NULL DEFAULT '2016-01-01 00:00:00'::timestamp without time zone,
	CONSTRAINT zoom_webinar_registration_pkey PRIMARY KEY (id)
);

/* zoom_webinar_attendance on test schema */
CREATE TABLE test.zoom_webinar_attendance (
	u_event_id text null,
	id_sequence text NULL,
	id text NOT NULL DEFAULT ''::text,
	user_id text NULL,
	email text NULL,
	first_name text NULL,
	last_name text NULL,
	event_id text NULL,
	joined_timestamp timestamp NULL DEFAULT '2016-01-01 00:00:00'::timestamp without time zone,
	left_timestamp timestamp NULL DEFAULT '2016-01-01 00:00:00'::timestamp without time zone,
	duration_second int4 NULL DEFAULT 1,
	start_time timestamp NULL DEFAULT '2016-01-01 00:00:00'::timestamp without time zone,
	CONSTRAINT zoom_webinar_attendance_pkey PRIMARY KEY (id)
);

/* zoom_webinar_panelist on test schema */
CREATE TABLE test.zoom_webinar_panelist (
	u_event_id text NULL,
	event_id text NULL,
	id text NOT NULL DEFAULT ''::text,
	email text NULL,
	panelist_full_name text NULL,
	CONSTRAINT zoom_webinar_panelist_pkey PRIMARY KEY (id)
);


/*****

ZOOM MEETING TABLES

*****/
/* zoom_meeting_event on test schema */
CREATE TABLE test.zoom_meeting_event (
	u_event_id text null,
	uuid text NULL,
	event_id text NOT NULL DEFAULT ''::text,
	event_name text,
	event_city text,
	event_country_region text,
	organising_chapter text,
	start_time timestamp NULL DEFAULT '2016-01-01 00:00:00'::timestamp without time zone,
	duration_minutes int4 NULL DEFAULT 1,
	event_status text NULL,
	CONSTRAINT zoom_meeting_event_pkey PRIMARY KEY (event_id)
);

/* zoom_meeting_registration on test schema */
CREATE TABLE test.zoom_meeting_registration (
	u_event_id text null,
	id text NOT NULL DEFAULT ''::text,
	email text NULL,
	first_name text NULL,
	last_name text NULL,
	gender text NULL,
	age_group text NULL,
	city text NULL,
	country_region text NULL,
	current_industry text NULL,
	current_job_level text NULL,
	current_comopany text NULL,
	latest_role text NULL,
	status text NULL,
	registration_timestamp timestamp NULL DEFAULT '2016-01-01 00:00:00'::timestamp without time zone,
	CONSTRAINT zoom_meeting_registration_pkey PRIMARY KEY (id)
);

/* zoom_meeting_attendance on test schema */
CREATE TABLE test.zoom_meeting_attendance (
	u_event_id text null,
	id_sequence text NULL,
	id text NOT NULL DEFAULT ''::text,
	user_id text NULL,
	email text NULL,
	first_name text NULL,
	last_name text NULL,
	event_id text NULL,
	joined_timestamp timestamp NULL DEFAULT '2016-01-01 00:00:00'::timestamp without time zone,
	left_timestamp timestamp NULL DEFAULT '2016-01-01 00:00:00'::timestamp without time zone,
	duration_second int4 NULL DEFAULT 1,
	start_time timestamp NULL DEFAULT '2016-01-01 00:00:00'::timestamp without time zone,
	CONSTRAINT zoom_meeting_attendance_pkey PRIMARY KEY (id)
);

/* zoom_meeting_panelist on test schema */
CREATE TABLE test.zoom_meeting_panelist (
	u_event_id text NULL,
	event_id text NULL,
	id text NOT NULL DEFAULT ''::text,
	email text NULL,
	panelist_full_name text NULL,
	CONSTRAINT zoom_meeting_panelist_pkey PRIMARY KEY (id)
);
