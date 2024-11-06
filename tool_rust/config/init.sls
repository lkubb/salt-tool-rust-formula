# vim: ft=sls

{#-
    Manages the Rust package configuration by

    * recursively syncing from a dotfiles repo

    Has a dependency on `tool_rust.package`_.
#}

include:
  - .sync
