# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as rust with context %}
{%- set sls_actual_install = slsdotpath ~ '.' ~ rust.install_method %}

# @FIXME install rustup-init platform-independently or official
# packages from https://forge.rust-lang.org/infra/other-installation-methods.html#standalone-installers

{%- if salt['state.sls_exists'](sls_actual_install) %}

include:
  - {{ sls_actual_install }}

{%- else %}

Rustup is installed:
  pkg.installed:
    - pkg: {{ rust.lookup.pkg.name }}

{%-   for user in rust.users %}

Rust toolchain is installed for user '{{ user.name }}':
  cmd.run:
    - name: rustup toolchain install '{{ rust.version or 'stable' }}'
    - runas: {{ user.name }}
    - unless:
      - sudo -u {{ user.name }} rustup toolchain list | grep '{{ rust.version or 'alwaysfails' }}'
    - require:
      - Rustup is installed
    - require_in:
      - Rust setup is completed
{%-   endfor %}
{%- endif %}

Rust setup is completed:
  test.nop:
    - name: Hooray, Rust setup has finished.
