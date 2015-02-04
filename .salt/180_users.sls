{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
include:
  - makina-states.services.db.postgresql.hooks
{% import "makina-states/services/db/postgresql/init.sls" as pgsql with context %}

{% import "makina-projects/{0}/task_read_roles.sls".format(cfg.name) as roles with context %}
{% for group, gdata in roles.groups.items() %}
{{ pgsql.postgresql_group(group, **gdata) }}
{%endfor %}    

{% for user, udata in roles.users.items() %}
{{ pgsql.postgresql_user(user, **udata) }}
{%endfor %}

