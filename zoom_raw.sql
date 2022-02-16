
    CREATE SCHEMA IF NOT EXISTS zoom;

    
    DROP TABLE IF EXISTS zoom.attendee_raw;

    CREATE TABLE zoom.attendee_raw (
        attended text NULL,user_name_original_name text NULL,first_name text NULL,last_name text NULL,email text NULL,city text NULL,countryregion text NULL,phone text NULL,organization text NULL,registration_time text NULL,approval_status text NULL,join_time text NULL,leave_time text NULL,time_in_session_minutes text NULL,gender text NULL,whats_your_age_bracket text NULL,in_which_industry_do_you_work text NULL,if_selected_others_for_the_previous_question_please_specify text NULL,what_is_the_functional_role_of_your_latest_job_position text NULL,if_selected_others_for_previous_question_please_specify text NULL,what_is_your_job_level text NULL,how_did_you_find_out_about_this_event text NULL,agree_to_terms__conditions_httpsshelovesdatacomtermsandconditions_and_privacy_policy_httpsshelovesdatacomprivacypolicy text NULL,countryregion_name text NULL,_id text NULL,event_id text NULL,source_name text NULL,what_is_your_job_level_
 text NULL,
    CONSTRAINT attendee_raw_pkey PRIMARY KEY (_id)
    );
     
    \COPY zoom.attendee_raw FROM '/home/karenion/Documents/volunteer/sld/sld_sql/../data/attendee_cleaned.csv' DELIMITER ',' CSV HEADER;
    
    DROP TABLE IF EXISTS zoom.registration_raw;

    CREATE TABLE zoom.registration_raw (
        first_name text NULL,last_name text NULL,email text NULL,city text NULL,countryregion text NULL,phone text NULL,organization text NULL,registration_time text NULL,approval_status text NULL,gender text NULL,whats_your_age_bracket text NULL,in_which_industry_do_you_work text NULL,if_selected_others_for_the_previous_question_please_specify text NULL,what_is_the_functional_role_of_your_latest_job_position text NULL,if_selected_others_for_previous_question_please_specify text NULL,what_is_your_job_level text NULL,how_did_you_find_out_about_this_event text NULL,agree_to_terms__conditions_httpsshelovesdatacomtermsandconditions_and_privacy_policy_httpsshelovesdatacomprivacypolicy text NULL,countryregion_name text NULL,attendance_type text NULL,_id text NULL,event_id text NULL,what_is_your_job_level_ text NULL,source_name text NULL,agree_to_terms_and_conditions_and_privacy_policy text NULL,attended_yn text NULL,attended text NULL,date_au text NULL,date_us text NULL,event_name text NULL,organizing_chapter text NULL,event_type text NULL,zoom_event_type
 text NULL,
    CONSTRAINT registration_raw_pkey PRIMARY KEY (_id)
    );
     
    \COPY zoom.registration_raw FROM '/home/karenion/Documents/volunteer/sld/sld_sql/../data/registration_cleaned.csv' DELIMITER ',' CSV HEADER;
    