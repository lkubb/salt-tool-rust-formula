# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``tool_rust`` meta-state
    in reverse order.
#}

include:
  - .crates.clean
  - .config.clean
  - .env_vars.clean
  - .package.clean
