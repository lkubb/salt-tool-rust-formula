# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as rust with context %}

{%- if rust.require_asdf %}

include:
  - {{ rust.require_asdf }}
{%- endif %}


{%- for user in rust.users %}

Rust is installed for user '{{ user.name }}':
  asdf.version_installed:
    - name: rust
    - version: {{ rust.version or 'latest' }}
    - user: {{ user.name }}
    - require_in:
      - Rust setup is completed
{%-   if rust.require_asdf %}
    - require:
      - sls: {{ rust.require_asdf }}
{%-   endif %}
{%- endfor %}
