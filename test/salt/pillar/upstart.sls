# -*- coding: utf-8 -*-
# vim: ft=yaml
---
tool_global:
  users:
    user:
      completions: .completions
      configsync: true
      persistenv: .bash_profile
      rchook: .bashrc
      xdg: true
      rust:
        crates:
          - broot
          - du-dust
tool_rust:
  lookup:
    master: template-master
    # Just for testing purposes
    winner: lookup
    added_in_lookup: lookup_value

    pkg:
      name: rustup
    paths:
      confdir: '.cargo'
      conffile: 'config.toml'
      xdg_dirname: 'cargo'
      xdg_conffile: 'config.toml'
    require_asdf: tool_asdf
    rustup_init:
      hash: a3cb081f88a6789d104518b30d4aa410009cd08c3822a1226991d6cf0442a0f8
      name: rustup-init.sh
      source: https://sh.rustup.rs
  install_method: web

  tofs:
    # The files_switch key serves as a selector for alternative
    # directories under the formula files directory. See TOFS pattern
    # doc for more info.
    # Note: Any value not evaluated by `config.get` will be used literally.
    # This can be used to set custom paths, as many levels deep as required.
    files_switch:
      - any/path/can/be/used/here
      - id
      - roles
      - osfinger
      - os
      - os_family
    # All aspects of path/file resolution are customisable using the options below.
    # This is unnecessary in most cases; there are sensible defaults.
    # path_prefix: template_alt
    # dirs:
    #   files: files_alt
    #   default: default_alt
    # The entries under `source_files` are prepended to the default source files
    # given for the state
    # source_files:
    #   tool-rust-config-file-file-managed:
    #     - 'example_alt.tmpl'
    #     - 'example_alt.tmpl.jinja'

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
