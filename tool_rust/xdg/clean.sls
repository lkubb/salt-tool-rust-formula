# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as rust with context %}


{%- for user in rust.users | rejectattr('xdg', 'sameas', False) %}

{%-   set user_default_conf = user.home | path_join(rust.lookup.paths.confdir) %}
{%-   set user_xdg_datadir = user.xdg.data | path_join(rust.lookup.paths.xdg_dirname) %}

Cargo data is cluttering $HOME for user '{{ user.name }}':
  file.rename:
    - name: {{ user_default_conf }}
    - source: {{ user_xdg_datadir }}

Cargo does not use XDG dirs during this salt run:
  environ.setenv:
    - value:
        CARGO_HOME: false
        CARGO_INSTALL_ROOT: false
    - false_unsets: true

{%-   if user.get('persistenv') %}

Cargo is ignorant about XDG location for user '{{ user.name }}':
  file.replace:
    - name: {{ user.home | path_join(user.persistenv) }}
    - text: {{ ('^(' ~ ('export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share/' ~ rust.lookup.paths.xdg_dirname ~ '"')
              | regex_escape ~ '|' ~ ('export CARGO_INSTALL_ROOT="$HOME/.local"' | regex_escape) ~ ')$') | yaml }}
    - repl: ''
    - ignore_if_missing: true
{%-   endif %}
{%- endfor %}
