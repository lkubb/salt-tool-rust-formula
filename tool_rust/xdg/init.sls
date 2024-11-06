# vim: ft=sls

{#-
    Ensures Rust adheres to the XDG spec
    as best as possible for all managed users.
    Has a dependency on `tool_rust.package`_.
#}

include:
  - .migrated
