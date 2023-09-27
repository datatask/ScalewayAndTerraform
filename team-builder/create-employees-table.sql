CREATE TABLE IF NOT EXISTS {{.DBSchema}}.{{.DBEmployeesTable}}
(
    email text COLLATE pg_catalog."default" NOT NULL,
    first_name text COLLATE pg_catalog."default" NOT NULL,
    last_name text COLLATE pg_catalog."default" NOT NULL,
    job_title text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT {{.DBEmployeesTable}}_pkey PRIMARY KEY (email)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS {{.DBSchema}}.{{.DBEmployeesTable}}
    OWNER to "{{.DBUser}}";