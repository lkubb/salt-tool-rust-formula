# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as rust with context %}

include:
  - {{ tplroot }}.package.install


{%- for user in rust.users
    | selectattr('persistenv', 'defined')
    | selectattr('persistenv')
    | selectattr('_rust.env') %}

persistenv file for Rust for user '{{ user.name }}' exists:
  file.managed:
    - name: {{ user.home | path_join(user.persistenv) }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - replace: false
    - mode: '0600'
    - dir_mode: '0700'
    - makedirs: true

{%-   for conf, val in user._rust.env.items() %}

Rust env var '{{ conf | upper }}' is persisted for '{{ user.name }}':
  file.append:
    - name: {{ user.home | path_join(user.persistenv) }}
    - text: export {{ conf | upper }}="{{ val }}"
    - require:
      - persistenv file for Rust for user '{{ user.name }}' exists
      - sls: {{ tplroot }}.package.install
{%-   endfor %}
{%- endfor %}
