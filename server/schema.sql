CREATE TYPE shot_block_type AS ENUM (
    'none',
    'dmca',
    'abuse',
    'usererror',
    'watchdog'
);
ALTER TYPE shot_block_type OWNER TO chenba;
CREATE TABLE accounts (
    id character varying(200) NOT NULL,
    token text,
    avatarurl text,
    nickname text,
    email text
);
CREATE TABLE data (
    id character varying(270) NOT NULL,
    deviceid character varying(200),
    created timestamp without time zone DEFAULT now(),
    value text NOT NULL,
    url text,
    expire_time timestamp without time zone DEFAULT (now() + '14 days'::interval),
    deleted boolean DEFAULT false NOT NULL,
    title text,
    searchable_text tsvector,
    searchable_version integer,
    block_type shot_block_type DEFAULT 'none'::shot_block_type NOT NULL
);
CREATE TABLE devices (
    id character varying(200) NOT NULL,
    accountid character varying(200),
    last_addon_version text,
    last_login timestamp without time zone,
    created timestamp without time zone DEFAULT now(),
    session_count integer DEFAULT 0,
    secret_hashed text,
    ab_tests text
);
CREATE TABLE images (
    id character varying(200) NOT NULL,
    shotid character varying(270) NOT NULL,
    clipid character varying(200) NOT NULL,
    contenttype text NOT NULL,
    url text,
    size integer,
    failed_delete boolean DEFAULT false NOT NULL
);
CREATE TABLE metrics_cache (
    created timestamp without time zone DEFAULT now(),
    data text
);
CREATE TABLE property (
    key text NOT NULL,
    value text
);
CREATE TABLE signing_keys (
    created timestamp without time zone DEFAULT now(),
    key text
);
CREATE TABLE states (
    state character varying(64) NOT NULL,
    deviceid character varying(200)
);
CREATE TABLE watchdog_submissions (
    id integer NOT NULL,
    shot_id character varying(270) NOT NULL,
    request_id character(36) NOT NULL,
    nonce character(36) NOT NULL,
    positive_result boolean
);
CREATE SEQUENCE watchdog_submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE watchdog_submissions_id_seq OWNED BY watchdog_submissions.id;
ALTER TABLE ONLY watchdog_submissions ALTER COLUMN id SET DEFAULT nextval('watchdog_submissions_id_seq'::regclass);
ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);
ALTER TABLE ONLY data
    ADD CONSTRAINT data_pkey PRIMARY KEY (id);
ALTER TABLE ONLY devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);
ALTER TABLE ONLY images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);
ALTER TABLE ONLY property
    ADD CONSTRAINT property_pkey PRIMARY KEY (key);
ALTER TABLE ONLY states
    ADD CONSTRAINT states_pkey PRIMARY KEY (state);
ALTER TABLE ONLY watchdog_submissions
    ADD CONSTRAINT watchdog_pkey PRIMARY KEY (id);
CREATE INDEX data_deviceid_idx ON data USING btree (deviceid);
CREATE INDEX devices_accountid_idx ON devices USING btree (accountid);
CREATE INDEX images_shotid_idx ON images USING btree (shotid);
CREATE INDEX searchable_text_idx ON data USING gin (searchable_text);
CREATE INDEX states_deviceid_idx ON states USING btree (deviceid);
ALTER TABLE ONLY data
    ADD CONSTRAINT data_deviceid_fkey FOREIGN KEY (deviceid) REFERENCES devices(id) ON DELETE CASCADE;
ALTER TABLE ONLY devices
    ADD CONSTRAINT devices_accountid_fkey FOREIGN KEY (accountid) REFERENCES accounts(id) ON DELETE SET NULL;
ALTER TABLE ONLY images
    ADD CONSTRAINT images_shotid_fkey FOREIGN KEY (shotid) REFERENCES data(id) ON DELETE CASCADE;
ALTER TABLE ONLY states
    ADD CONSTRAINT states_deviceid_fkey FOREIGN KEY (deviceid) REFERENCES devices(id) ON DELETE CASCADE;
ALTER TABLE ONLY watchdog_submissions
    ADD CONSTRAINT watchdog_shot_id_fkey FOREIGN KEY (shot_id) REFERENCES data(id) ON DELETE CASCADE;
-- pg-patch version: 23
