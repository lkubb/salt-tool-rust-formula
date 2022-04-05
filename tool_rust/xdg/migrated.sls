# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as rust with context %}

include:
  - {{ tplroot }}.package


{%- for user in rust.users | rejectattr('xdg', 'sameas', False) %}

{%-   set user_default_conf = user.home | path_join(rust.lookup.paths.confdir) %}
{%-   set user_xdg_datadir = user.xdg.data | path_join(rust.lookup.paths.xdg_dirname) %}

# workaround for file.rename not supporting user/group/mode for makedirs
XDG_DATA_HOME exists for Cargo for user '{{ user.name }}':
  file.directory:
    - name: {{ user.xdg.data }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0700'
    - makedirs: true
    - onlyif:
      - test -e '{{ user_default_conf }}'

Existing Cargo data is migrated for user '{{ user.name }}':
  file.rename:
    - name: {{ user_xdg_datadir }}
    - source: {{ user_default_conf }}
    - require:
      - XDG_DATA_HOME exists for Cargo for user '{{ user.name }}'
    - require_in:
      - Rust setup is completed

Rust has its data dir in XDG_DATA_HOME for user '{{ user.name }}':
  file.directory:
    - name: {{ user_xdg_datadir }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - makedirs: true
    - mode: '0700'
    - require:
      - Existing Cargo data is migrated for user '{{ user.name }}'
    - require_in:
      - Rust setup is completed

# @FIXME
# This actually does not make sense and might be harmful:
# Each file is executed for all users, thus this breaks
# when more than one is defined!
Rust uses XDG dirs during this salt run:
  environ.setenv:
    - value:
        CARGO_HOME: "{{ user_xdg_datadir }}"
        # installs binaries into ~/.local/bin
        CARGO_INSTALL_ROOT: "{{ user.home | path_join('.local') }}"
    - require_in:
      - Rust setup is completed

{%-   if user.get('persistenv') %}

persistenv file for Rust exists for user '{{ user.name }}':
  file.managed:
    - name: {{ user.home | path_join(user.persistenv) }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - replace: false
    - mode: '0600'
    - dir_mode: '0700'
    - makedirs: true

Rust knows about XDG location for user '{{ user.name }}':
  file.append:
    - name: {{ user.home | path_join(user.persistenv) }}
    - text: |
        export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/{{ rust.lookup.paths.xdg_dirname }}"
        export CARGO_INSTALL_ROOT="$HOME/.local"
    - require:
      - persistenv file for Rust exists for user '{{ user.name }}'
    - require_in:
      - Rust setup is completed
{%-   endif %}
{%- endfor %}
