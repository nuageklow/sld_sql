-- create table
CREATE TABLE zoom.zoom_gui_registration (
  id text NOT NULL default ''::text,
  event_id text NULL,
  email text NULL,
  status text NULL,
  first_name text NULL,
  last_name text NULL,
  age_group text NULL,
  gender text NULL,
  city text NULL,
  country_region text NULL,
  current_industry text NULL,
  current_job_level text NULL,
  current_company text NULL,
  latest_role text NULL,
  event_referred_source text NULL,
  registration_timestamp timestamp NULL DEFAULT '2016-01-01 00:00:00'::timestamp WITHOUT time zone,
  report_type text NULL
  CONSTRAINT zoom_gui_registration_pkey PRIMARY KEY (id)
);

CREATE TABLE zoom_gui

CREATE TABLE zoom_gui_registration AS (
SELECT
)
