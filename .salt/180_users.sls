{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
{% set pgsql = salt['mc_pgsql.settings']() %}
include:
  - makina-states.services.db.postgresql.hooks

{% import "makina-states/services/db/postgresql/init.sls" as pgsql with context %}
{% import "makina-projects/{0}/include/read_roles.sls".format(cfg.name) as roles with context %}  

{# users & groups #}
{% for group, gdata in roles.groups.items() %}
{{ pgsql.postgresql_group(group, **gdata) }}
{%endfor %}    

{% for user, udata in roles.users.items() %}
{{ pgsql.postgresql_user(user, **udata) }}
{%endfor %}
