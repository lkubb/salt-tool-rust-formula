{%- from 'tool-rust/map.jinja' import rust -%}

include:
 - .package

{%- for user in rust.users | selectattr('rust.crates', 'defined') %}
  {%- for package in user.rust.packages %}
Rust package '{{ package }}' is installed via Cargo for user '{{ user.name }}':
  cargo.installed:
    - name: {{ package }}
    - user: {{ user.name }}
    - require:
      - Rust setup is completed
  {%- endfor %}
{%- endfor %}
