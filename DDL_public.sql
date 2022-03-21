CREATE TABLE public.event_label_mapping (
	u_event_id text NOT NULL DEFAULT ''::text,
	event_name text NULL DEFAULT ''::text,
	event_date text NULL DEFAULT '1984-11-17'::date,
	chapter text NULL DEFAULT ''::text,
	event_type text NULL DEFAULT ''::text,
	event_topic text NULL DEFAULT ''::text,
	"level" text NULL DEFAULT ''::text,
	online_offline text NULL DEFAULT ''::text,
	registration_source text NULL DEFAULT ''::text,
	event_focus_skill text NULL DEFAULT ''::text,
	hash_mechanics text NULL DEFAULT ''::text,
	event_status text NULL DEFAULT ''::text,
	long_term_certification_program text NULL,
	batch_processing_date timestamp(0) NULL,
	CONSTRAINT event_label_mapping_lindsay_pkey PRIMARY KEY (u_event_id)
);


