# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as rust with context %}

# @FIXME install rustup-init platform-independently or official
# packages from https://forge.rust-lang.org/infra/other-installation-methods.html#standalone-installers

Rustup-init is installed:
  pkg.installed:
    - name: {{ rust.lookup.pkg.name }}

Rust is installed:
  cmd.run:
    - name: rustup-init -y

Rust setup is completed:
  test.nop:
    - name: Hooray, Rust setup has finished.
    - require:
      - pkg: {{ rust.lookup.pkg.name }}
