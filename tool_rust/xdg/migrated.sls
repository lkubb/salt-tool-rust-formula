# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as rust with context %}

include:
  - {{ tplroot }}.package
  - {{ tplroot }}.env_vars


{%- for user in rust.users | rejectattr("xdg", "sameas", false) %}

{%-   set user_default_conf = user.home | path_join(rust.lookup.paths.confdir) %}
{%-   set user_xdg_datadir = user.xdg.data | path_join(rust.lookup.paths.xdg_dirname) %}
{%-   set user_rustup_default_conf = user.home | path_join(rust.lookup.paths.rustup_confdir) %}
{%-   set user_rustup_xdg_datadir = user.xdg.data | path_join(rust.lookup.paths.rustup_xdg_dirname) %}

# workaround for file.rename not supporting user/group/mode for makedirs
XDG_DATA_HOME exists for Rust for user '{{ user.name }}':
  file.directory:
    - name: {{ user.xdg.data }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0700'
    - makedirs: true
    - onlyif:
      - test -e '{{ user_default_conf }}'
{%-   if rust.install_method == "web" %}
      - test -e '{{ user_rustup_default_conf }}'
{%-   endif %}

Existing Rust data is migrated for user '{{ user.name }}':
  file.rename:
    - names:
      - {{ user_xdg_datadir }}:
        - source: {{ user_default_conf }}
{%-   if rust.install_method == "web" %}
      - {{ user_rustup_xdg_datadir }}:
        - source: {{ user_rustup_default_conf }}
{%-   endif %}
    - require:
      - XDG_DATA_HOME exists for Rust for user '{{ user.name }}'
    - require_in:
      - Rust setup is completed

Rust has its data dir in XDG_DATA_HOME for user '{{ user.name }}':
  file.directory:
    - names:
      - {{ user_xdg_datadir }}
{%-   if rust.install_method == "web" %}
      - {{ user_rustup_xdg_datadir }}
{%-   endif %}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - makedirs: true
    - mode: '0700'
    - require:
      - Existing Rust data is migrated for user '{{ user.name }}'
    - require_in:
      - Rust setup is completed

# @FIXME
# This actually does not make sense and might be harmful:
# Each file is executed for all users, thus this breaks
# when more than one is defined!
Rust uses XDG dirs during this salt run:
  environ.setenv:
    - value:
        CARGO_HOME: "{{ user_xdg_datadir }}"
        # installs binaries into ~/.local/bin
        CARGO_INSTALL_ROOT: "{{ user.home | path_join('.local') }}"
{%-   if rust.install_method == "web" %}
        RUSTUP_HOME: "{{ user_rustup_xdg_datadir }}"
{%-   endif %}
    - require_in:
      - Rust setup is completed
{%- endfor %}
