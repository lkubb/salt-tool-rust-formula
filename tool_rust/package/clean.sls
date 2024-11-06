# vim: ft=sls

{#-
    Removes the Rust package.
    Has a dependency on `tool_rust.config.clean`_.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_clean = tplroot ~ ".config.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as rust with context %}

include:
  - {{ sls_config_clean }}
{%- if salt["state.sls_exists"](sls_actual_install) %}
  - {{ sls_actual_install }}.clean

{%- else %}

{%-   for user in rust.users %}

Rust toolchain is removed for user '{{ user.name }}':
  cmd.run:
    - name: rustup toolchain uninstall '{{ rust.version or "stable" }}'
    - runas: {{ user.name }}
    - onlyif:
      - test -z '{{ rust.version }}' || sudo -u {{ user.name }} rustup toolchain list | grep '{{ rust.version }}'
    - require_in:
      - Rustup is removed
{%-   endfor %}

Rustup is removed:
  pkg.removed:
    - pkg: {{ rust.lookup.pkg.name }}

{%- endif %}
