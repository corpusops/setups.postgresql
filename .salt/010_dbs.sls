{% set cfg = opts.ms_project %}
include:
  - makina-states.services.db.postgresql
{% import "makina-states/services/db/postgresql/init.sls" as pgsql with context %}
{% set data = cfg.data %}
{% for dbext in data.databases %}
{% for db, dbdata in dbext.items() %}
{{ pgsql.postgresql_db(db, template="postgis", wait_for_template=False) }}
{{ pgsql.postgresql_user(dbdata.user, password=dbdata.password, db=db, suf=db) }}
{{ pgsql.install_pg_ext('hstore', db) }}
{%endfor %}
{%endfor%}
