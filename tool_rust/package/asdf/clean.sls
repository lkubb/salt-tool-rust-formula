# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_clean = tplroot ~ ".config.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as rust with context %}

include:
  - {{ sls_config_clean }}
{%- if rust.require_asdf %}
  - {{ rust.require_asdf }}
{%- endif %}


{%- for user in rust.users %}

Rust is removed for user '{{ user.name }}':
  asdf.version_absent:
    - name: rust
    - version: {{ rust.version or "latest" }}
    - user: {{ user.name }}
    - require:
      - sls: {{ sls_config_clean }}
{%-   if rust.require_asdf %}
      - sls: {{ rust.require_asdf }}
{%-   endif %}
{%- endfor %}
