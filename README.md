# Rust Formula
Sets up, configures and updates Rust and Cargo.

## Usage
Applying `tool-rust` will make sure Cargo is configured as specified. This formula mostly exists for the `cargo` state module.

### Execution module and state
This formula provides a custom execution module and state to manage packages installed with Cargo. The functions are self-explanatory, please see the source code for comments. Currently, the following states are supported:
* `cargo.installed(name, version=None, locked=True, root=None, force=False, git=None, path=None, branch=None, tag=None, rev=None, user=None)`
* `cargo.absent(name, root=None, user=None)`
* `cargo.latest(name, locked=True, root=None, user=None)`

## Configuration
### Pillar
#### General `tool` architecture
Since installing user environments is not the primary use case for saltstack, the architecture is currently a bit awkward. All `tool` formulas assume running as root. There are three scopes of configuration:
1. per-user `tool`-specific
  > e.g. generally force usage of XDG dirs in `tool` formulas for this user
2. per-user formula-specific
  > e.g. setup this tool with the following configuration values for this user
3. global formula-specific (All formulas will accept `defaults` for `users:username:formula` default values in this scope as well.)
  > e.g. setup system-wide configuration files like this

**3** goes into `tool:formula` (e.g. `tool:git`). Both user scopes (**1**+**2**) are mixed per user in `users`. `users` can be defined in `tool:users` and/or `tool:formula:users`, the latter taking precedence. (**1**) is namespaced directly under `username`, (**2**) is namespaced under `username: {formula: {}}`.

```yaml
tool:
######### user-scope 1+2 #########
  users:                         #
    username:                    #
      xdg: true                  #
      dotconfig: true            #
      formula:                   #
        config: value            #
####### user-scope 1+2 end #######
  formula:
    formulaspecificstuff:
      conf: val
    defaults:
      yetanotherconfig: somevalue
######### user-scope 1+2 #########
    users:                       #
      username:                  #
        xdg: false               #
        formula:                 #
          otherconfig: otherval  #
####### user-scope 1+2 end #######
```

#### User-specific
The following shows an example of `tool-rust` pillar configuration. Namespace it to `tool:users` and/or `tool:rust:users`.
```yaml
user:
  xdg: true                         # force xdg dirs
  dotconfig: true                   # sync this user's config from a dotfiles repo available as salt://dotconfig/<user>/rust or salt://dotconfig/rust
  persistenv: '.config/zsh/zshenv'  # persist env vars specified in salt to this file (will be appended to file relative to $HOME)
  rust:
    # crates that should be installed for this user
    crates:
      - broot
      - du-dust
```

#### Formula-specific
```yaml
tool:
  rust:
    update_auto: true               # keep the packages updated to their latest version on subsequent runs (for Linux, brew does that anyways)
    defaults:                       # default formula configuration for all users
      # default crates that should be installed with cargo
      # (for further config, use cargo.installed in your own state)
      crates:
        - flavours
```

### Dotfiles
`tool-rust.configsync` will sync `config.toml` from

- `salt://dotconfig/<user>/cargo` or
- `salt://dotconfig/cargo`

to `${CARGO_HOME:-$HOME/.cargo}` for every user that has it enabled (see `user.dotconfig`).
