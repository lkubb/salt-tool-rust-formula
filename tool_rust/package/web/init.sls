# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as rust with context %}
{%- set tmp = salt['temp.dir']() %}


Rustup-init is available:
  file.managed:
    - name: {{ tmp | path_join(rust.lookup.rustup_init.name) }}
    - source: {{ rust.lookup.rustup_init.source }}
    - source_hash: {{ rust.lookup.rustup_init.hash }}
    - mode: '0777'

{%- for user in rust.users %}

Rustup is installed for user '{{ user.name }}':
  cmd.run:
    - name: {{ tmp | path_join(rust.lookup.rustup_init.name) }} -y
    - runas: {{ user.name }}
{%-   if user._rust.env %}
    - env:
{%-     for var, val in user._rust.env.items() %}
        {{ var }}: {{ val }}
{%-     endfor %}
{%-   endif %}
    - require:
      - Rustup-init is available
    - require_in:
      - Rustup-init is absent
    - unless:
      - sudo -u '{{ user.name }}' command -v rustup

Rust toolchain is installed for user '{{ user.name }}':
  cmd.run:
    - name: rustup toolchain install '{{ rust.version or 'stable' }}'
    - runas: {{ user.name }}
{%-   if user._rust.env %}
    - env:
{%-     for var, val in user._rust.env.items() %}
        {{ var }}: {{ val }}
{%-     endfor %}
{%-   endif %}
    - unless:
      - sudo -u {{ user.name }} rustup toolchain list | grep '{{ rust.version or 'alwaysfails' }}'
    - require:
      - Rustup is installed for user '{{ user.name }}'
    - require_in:
      - Rust setup is completed
{%- endfor %}

Rustup-init is absent:
  file.absent:
    - name: {{ tmp | path_join(rust.lookup.rustup_init.name) }}
