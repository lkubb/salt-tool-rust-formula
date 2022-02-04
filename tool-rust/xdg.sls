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
    - require_in:
      - Rust setup is completed

Cargo uses XDG dirs during this salt run:
  environ.setenv:
    - value:
        CARGO_HOME: "{{ user.xdg.data }}/cargo"
        CARGO_INSTALL_ROOT: "{{ user.home }}/.local"
    - require_in:
      - Rust setup is completed

  {%- if user.get('persistenv') %}

persistenv file for rust for user '{{ user.name }}' exists:
  file.managed:
    - name: {{ user.home }}/{{ user.persistenv }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0600'
    - dir_mode: '0700'
    - makedirs: true

Cargo knows about XDG location for user '{{ user.name }}':
  file.append:
    - name: {{ user.home }}/{{ user.persistenv }}
    - text: |
        export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
        export CARGO_INSTALL_ROOT="$HOME/.local"
    - require:
      - persistenv file for rust for user '{{ user.name }}' exists
    - require_in:
      - Rust setup is completed
  {%- endif %}
{%- endfor %}
