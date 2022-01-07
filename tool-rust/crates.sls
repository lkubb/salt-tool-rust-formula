{%- from 'tool-rust/map.jinja' import rust -%}

{%- for user in rust.users | selectattr('rust.crates', 'defined') %}
  {%- for package in user.rust.packages %}
Rust package '{{ package }}' is installed via Cargo for user '{{ user.name }}':
  cargo.installed:
    - name: {{ package }}
    - user: {{ user.name }}
  {%- endfor %}
{%- endfor %}
