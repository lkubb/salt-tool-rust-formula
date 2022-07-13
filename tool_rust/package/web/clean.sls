# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as rust with context %}

include:
  - {{ sls_config_clean }}

{%- for user in rust.users %}

Rust toolchain is removed for user '{{ user.name }}':
  cmd.run:
    - name: rustup toolchain uninstall '{{ rust.version or 'stable' }}'
    - runas: {{ user.name }}
{%-   if user._rust.env %}
    - env:
{%-     for var, val in user._rust.env.items() %}
        {{ var }}: {{ val }}
{%-     endfor %}
{%-   endif %}
    - onlyif:
      - test -z '{{ rust.version }}' || sudo -u {{ user.name }} rustup toolchain list | grep '{{ rust.version }}'
    - require_in:
      - Rustup is removed

Rustup is removed for user '{{ user.name }}':
  cmd.run:
    - name: rustup self uninstall
    - runas: {{ user.name }}
{%- endfor %}
