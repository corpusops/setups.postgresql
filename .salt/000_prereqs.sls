{% set cfg = opts.ms_project %}
{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
{% set ver = pgsql.version %}
{% set db = cfg.data.db %}
include:
  - makina-states.services.gis.postgis
  - makina-states.services.gis.ubuntugis

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
      - pkgrepo: ubuntugis-pgrouting-base

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
