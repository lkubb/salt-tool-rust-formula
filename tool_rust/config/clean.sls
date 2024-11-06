# vim: ft=sls

{#-
    Removes the configuration of the Rust package.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as rust with context %}


{%- for user in rust.users %}

Rust data dir is absent for user '{{ user.name }}':
  file.absent:
    - name: {{ user["_rust"].datadir }}
{%- endfor %}
