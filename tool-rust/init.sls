{%- from 'tool-rust/map.jinja' import rust -%}

include:
  - .package
{%- if rust.users | rejectattr('xdg', 'sameas', False) %}
  - .xdg
{%- endif %}
{%- if rust.users | selectattr('dotconfig', 'defined') | selectattr('dotconfig') %}
  - .configsync
{%- endif %}
