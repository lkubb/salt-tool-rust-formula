{%- from 'tool-rust/map.jinja' import rust -%}

{%- for user in rust.users | selectattr('dotconfig', 'defined') | selectattr('dotconfig') %}
Cargo configuration is synced for user '{{ user.name }}':
  file.managed:
    - name: {{ user._rust.confdir }}/cargo.toml
    - source:
      - salt://dotconfig/{{ user.name }}/cargo/cargo.toml
      - salt://dotconfig/cargo/cargo.toml
    - context:
        user: {{ user | json }}
    - template: jinja
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0600'
    - dir_mode: '0700'
    - makedirs: True
{%- endfor %}
