{%- from 'tool-rust/map.jinja' import rust -%}

rust is installed:
{# Homebrew always installs latest, mac_brew_pkg does not support upgrading a single package #}
{%- if rust.get('update_auto') and not grains['kernel'] == 'Darwin' %}
  pkg.latest:
{%- else %}
  pkg.installed:
{%- endif %}
    - name: {{ rust._package }}

rust setup is completed:
  test.nop:
    - name: rust setup has finished, this state exists for technical reasons.
    - require:
      - pkg: {{ rust._package }}
