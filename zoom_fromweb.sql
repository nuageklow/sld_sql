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
  CONSTRAINT zoom_gui_registration_pkey PRIMARY KEY (id)
);

CREATE TABLE zoom_gui_registration AS (
SELECT

FROM
)


first_name	last_name	email	city	country/region	phone	organization	registration_time	approval_status	gender	whats_your_age_bracket?	in_which_industry_do_you_work?	if_selected_others_for_the_previous_question,_please_specify	what_is_the_functional_role_of_your_latest_job_position?	if_selected_others_for_previous_question,_please_specify	what_is_your_job_level?	how_did_you_find_out_about_this_event?	agree_to_terms_&_conditions_<https://shelovesdata.com/terms-and-conditions/>_and_privacy_policy_https://shelovesdata.com/privacy-policy/	country/region_name	attendance_type	event_id	what_is_your_job_level_?	agree_to_terms_&_conditions_<https://shelovesdata.com/terms-and-conditions/>_and_privacy_policy_<https://shelovesdata.com/privacy-policy/>	source_name	agree_to_terms_and_conditions_and_privacy_policy	attended_y/n	attended?	date_au	date_us	event_name	organizing_chapter	event_type	zoom_event_type	