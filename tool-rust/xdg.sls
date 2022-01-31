{%- from 'tool-rust/map.jinja' import rust -%}

include:
  - .package

{%- for user in rust.users | rejectattr('xdg', 'sameas', False) %}

Existing Cargo home is migrated for user '{{ user.name }}':
  file.rename:
    - name: {{ user.xdg.data }}/cargo
    - source: {{ user.home }}/.cargo
    - onlyif:
      - test -d {{ user.home }}/.cargo
    - makedirs: true
    - prereq_in:
      - Rust setup is completed

Cargo uses XDG dirs during this salt run:
  environ.setenv:
    - value:
        CARGO_HOME: "{{ user.xdg.data }}/cargo"
        CARGO_INSTALL_ROOT: "{{ user.home }}/.local"
    - prereq_in:
      - Rust setup is completed

  {%- if user.get('persistenv') %}
Cargo knows about XDG location for user '{{ user.name }}':
  file.append:
    - name: {{ user.home }}/{{ user.persistenv }}
    - text: |
        export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
        export CARGO_INSTALL_ROOT="$HOME/.local"
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0600'
    - prereq_in:
      - Rust setup is completed
  {%- endif %}
{%- endfor %}
