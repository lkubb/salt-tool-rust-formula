# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as rust with context %}


{%- for user in rust.users
    | selectattr("persistenv", "defined")
    | selectattr("persistenv")
    | selectattr("_rust.env") %}
{%-   for conf, val in user._rust.env %}

Rust env var '{{ conf | upper }}' is not persisted for '{{ user.name }}':
  file.replace:
    - name: {{ user.home | path_join(user.persistenv) }}
    - pattern: ^{{ 'export {}="{}"\n'.format(conf | upper, val) | regex_escape }}\n
    - repl: ''
{%-   endfor %}
{%- endfor %}
