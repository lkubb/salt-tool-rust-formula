# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as rust with context %}

include:
  - {{ tplroot }}.package.install


{%- for user in rust.users | selectattr('rust.crates', 'defined') %}
  {%- for package in user.rust.packages %}

Rust package '{{ package }}' is installed via Cargo for user '{{ user.name }}':
  cargo.installed:
    - name: {{ package }}
    - user: {{ user.name }}
    - require:
      - Rust setup is completed
  {%- endfor %}
{%- endfor %}
