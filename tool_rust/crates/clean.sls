# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as rust with context %}


{%- for user in rust.users | selectattr("rust.crates", "defined") %}
{%-   for package in user.rust.packages %}

Rust package '{{ package }}' is removed via Cargo for user '{{ user.name }}':
  cargo.absent:
    - name: {{ package }}
    - user: {{ user.name }}
{%-   endfor %}
{%- endfor %}
