{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
include:
  - makina-states.services.db.postgresql.hooks

{% import "makina-states/services/db/postgresql/init.sls" as pgsql with context %}
{% import "makina-projects/{0}/task_read_roles.sls".format(cfg.name) as roles with context %}

{% for dbext in data.databases %}
{% for db, dbdata in dbext.items() %}
{% set userdata = roles.users[dbdata.user] %}
{% do userdata.update({'suf': db}) %}
{% set t = dbdata.get('template', 'postgis') %}
{% set o = dbdata.get('owner', None) %}
{% if o is not none  and (o != dbdata.user) %}
{% do userdata.update({'db': db}) %}
{% endif %} 
{{ pgsql.postgresql_db(
  db, owner=o, template=t, wait_for_template=False, suf=db) }}
{{ pgsql.postgresql_user(dbdata.user, **userdata)}}
{{ pgsql.install_pg_ext('hstore', db) }}
{%endfor %}
{%endfor%}
