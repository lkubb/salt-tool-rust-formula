# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as rust with context %}


{%- for user in rust.users | rejectattr('xdg', 'sameas', false) %}

{%-   set user_default_conf = user.home | path_join(rust.lookup.paths.confdir) %}
{%-   set user_xdg_datadir = user.xdg.data | path_join(rust.lookup.paths.xdg_dirname) %}
{%-   set user_rustup_default_conf = user.home | path_join(rust.lookup.paths.rustup_confdir) %}
{%-   set user_rustup_xdg_datadir = user.xdg.data | path_join(rust.lookup.paths.rustup_xdg_dirname) %}

Rust data is cluttering $HOME for user '{{ user.name }}':
  file.rename:
    - names:
      - {{ user_default_conf }}:
        - source: {{ user_xdg_datadir }}
      - {{ user_rustup_default_conf }}:
        - source: {{ user_rustup_xdg_datadir }}

Rust does not use XDG dirs during this salt run:
  environ.setenv:
    - value:
        CARGO_HOME: false
        CARGO_INSTALL_ROOT: false
{%-   if 'web' == rust.install_method %}
        RUSTUP_HOME: false
{%-   endif %}
    - false_unsets: true
{%- endfor %}
