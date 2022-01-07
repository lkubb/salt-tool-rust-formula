{%- from 'tool-rust/map.jinja' import rust %}

{%- if rust.users | selectattr('dotconfig', 'defined') | selectattr('dotconfig') %}
include:
  - .configsync
{%- endif %}

rust is updated to latest version:
{%- if grains['kernel'] == 'Darwin' %}
  pkg.installed: # assumes homebrew as package manager. homebrew always installs the latest version, mac_brew_pkg does not support upgrading a single package
{%- else %}
  pkg.latest:
{%- endif %}
    - name: {{ rust._package }}
