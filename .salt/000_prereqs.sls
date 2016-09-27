{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
{% set pgsql = salt['mc_pgsql.settings']() %}
{% set ver = pgsql.version %}
{% set db = cfg.data.db %}
include:
  - makina-states.services.gis.postgis
  - makina-states.services.gis.ubuntugis
  - makina-states.services.backup.dbsmartbackup



{% set pkgssettings = salt['mc_pkgs.settings']() %}
{% if grains['os_family'] in ['Debian'] %}
{% set dist = pkgssettings.udist %}
{% endif %}
{% if grains['os'] in ['Debian'] %}
{% set dist = pkgssettings.ubuntu_lts %}
{% endif %}

pgrouting-{{cfg.name}}:
  pkg.latest:
    - pkgs:
      - postgresql-{{ver}}-pgrouting
    - watch:
      - pkg: ubuntugis-pkgs

{%for dsysctl in data.sysctls %}
{%for sysctl, val in dsysctl.items() %}
{% if val is not none %}
{{sysctl}}-{{cfg.name}}:
  sysctl.present:
    - config: /etc/sysctl.d/00_{{cfg.name}}sysctls.conf
    - name: {{sysctl}}
    - value: {{val}}
    - watch_in:
      - mc_proxy: makina-postgresql-pre-base
      - service: reload-sysctls-{{cfg.name}}
{% endif %}
{% endfor %}
{% endfor %}
{% set optim = data.get('pg_optim', []) %}
{% if optim %}
pgtune-{{cfg.name}}:
  file.managed:
    - name: /etc/postgresql/{{ver}}/main/conf.d/optim{{cfg.name}}.conf
    - source: ''
    - contents: |
                {% for o in optim %}
                {{o}}
                {% endfor %}
    - mode: 755
    - makedirs: true
    - group: user
    - group: root
    - watch:
      - mc_proxy: makina-postgresql-post-pkg
    - watch_in:
      - mc_proxy: makina-postgresql-presetup
      - service: reload-sysctls-{{cfg.name}}
{% endif %}
{% if grains['os'] in ['Ubuntu'] %}
reload-sysctls-{{cfg.name}}:
  service.running:
    - name: procps
    - enable: true
    - watch:
      - mc_proxy: makina-postgresql-pre-base
{% endif %}

{# backup #}
{% set dsb = salt['mc_dbsmartbackup.settings']() %}
{% for i in dsb.types %}
/etc/dbsmartbackup/{{i}}.conf.local:
  file.managed:
    - contents: |
                KEEP_LASTS="{{data.keep_lasts}}"
                KEEP_DAYS="{{data.keep_days}}"
                KEEP_WEEKS="{{data.keep_weeks}}"
                KEEP_MONTHES="{{data.keep_monthes}}"
                KEEP_LOGS="{{data.keep_logs}}"
    - mode: 644
    - user: root
    - group: root
{% endfor %}

/etc/db_smart_backup_deactivated:
{% if cfg.default_env in ['dev'] or data.get('backup_disabled', False)%}
  file.managed:
    - mode: 644
    - user: root
    - group: root
{%else %}
  file.absent: []
{% endif %}


