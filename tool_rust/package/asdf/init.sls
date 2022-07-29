# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as rust with context %}

{%- if rust.lookup.require_asdf %}

include:
  - {{ rust.lookup.require_asdf }}
{%- endif %}


{%- for user in rust.users %}

Rust is installed for user '{{ user.name }}':
  asdf.version_installed:
    - name: rust
    - version: {{ rust.version or 'latest' }}
    - user: {{ user.name }}
    - require_in:
      - Rust setup is completed
{%-   if rust.lookup.require_asdf %}
    - require:
      # cannot require files that do not have states themselves
      - sls: {{ rust.lookup.require_asdf }}.package.install
{%-   endif %}
{%- endfor %}
