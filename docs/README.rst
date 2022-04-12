.. _readme:

Rust Formula
============

Manages Rust toolchain in the user environment.

**Warning: This formula is currently broken.** Do not use it to manage the Rust toolchain. To fix it, it would be necessary to either make it install ``rustup`` or a specific package from the `standalone installers <https://forge.rust-lang.org/infra/other-installation-methods.html#standalone-installers>`_.

On the other hand, the ``cargo`` **modules are functional** and those are what this repository exists for currently.

.. contents:: **Table of Contents**
   :depth: 1

Usage
-----
Applying ``tool_rust`` will make sure ``rust`` is configured as specified.

Execution and state module
~~~~~~~~~~~~~~~~~~~~~~~~~~
This formula provides a custom execution module and state to manage packages installed with Rust. The functions are self-explanatory, please see the source code or the rendered docs at :ref:`em_rust` and :ref:`sm_rust`.

Configuration
-------------

This formula
~~~~~~~~~~~~
The general configuration structure is in line with all other formulae from the `tool` suite, for details see :ref:`toolsuite`. An example pillar is provided, see :ref:`pillar.example`. Note that you do not need to specify everything by pillar. Often, it's much easier and less resource-heavy to use the ``parameters/<grain>/<value>.yaml`` files for non-sensitive settings. The underlying logic is explained in :ref:`map.jinja`.

User-specific
^^^^^^^^^^^^^
The following shows an example of ``tool_rust`` per-user configuration. If provided by pillar, namespace it to ``tool_global:users`` and/or ``tool_rust:users``. For the ``parameters`` YAML file variant, it needs to be nested under a ``values`` parent key. The YAML files are expected to be found in

1. ``salt://tool_rust/parameters/<grain>/<value>.yaml`` or
2. ``salt://tool_global/parameters/<grain>/<value>.yaml``.

.. code-block:: yaml

  user:

      # Force the usage of XDG directories for this user.
    xdg: true

      # Sync this user's config from a dotfiles repo.
      # The available paths and their priority can be found in the
      # rendered `config/sync.sls` file (currently, @TODO docs).
      # Overview in descending priority:
      # salt://dotconfig/<minion_id>/<user>/cargo
      # salt://dotconfig/<minion_id>/cargo
      # salt://dotconfig/<os_family>/<user>/cargo
      # salt://dotconfig/<os_family>/cargo
      # salt://dotconfig/default/<user>/cargo
      # salt://dotconfig/default/cargo
    dotconfig:              # can be bool or mapping
      file_mode: '0600'     # default: keep destination or salt umask (new)
      dir_mode: '0700'      # default: 0700
      clean: false          # delete files in target. default: false

      # Persist environment variables used by this formula for this
      # user to this file (will be appended to a file relative to $HOME)
    persistenv: '.config/zsh/zshenv'

      # Add runcom hooks specific to this formula to this file
      # for this user (will be appended to a file relative to $HOME)
    rchook: '.config/zsh/zshrc'

      # This user's configuration for this formula. Will be overridden by
      # user-specific configuration in `tool_rust:users`.
      # Set this to `false` to disable configuration for this user.
    rust:
      crates:
        - broot
        - du-dust

Formula-specific
^^^^^^^^^^^^^^^^

.. code-block:: yaml

  tool_rust:

      # Specify an explicit version (works on most Linux distributions) or
      # keep the packages updated to their latest version on subsequent runs
      # by leaving version empty or setting it to 'latest'
      # (again for Linux, brew does that anyways).
    version: latest

      # Default formula configuration for all users.
    defaults:
      crates: default value for all users

Dotfiles
~~~~~~~~
``tool_rust.config.sync`` will recursively apply templates from

* ``salt://dotconfig/<minion_id>/<user>/cargo``
* ``salt://dotconfig/<minion_id>/cargo``
* ``salt://dotconfig/<os_family>/<user>/cargo``
* ``salt://dotconfig/<os_family>/cargo``
* ``salt://dotconfig/default/<user>/cargo``
* ``salt://dotconfig/default/cargo``

to the user's config dir for every user that has it enabled (see ``user.dotconfig``). The target folder will not be cleaned by default (ie files in the target that are absent from the user's dotconfig will stay).

The URL list above is in descending priority. This means user-specific configuration from wider scopes will be overridden by more system-specific general configuration.

Development
-----------

Contributing to this repo
~~~~~~~~~~~~~~~~~~~~~~~~~

Commit messages
^^^^^^^^^^^^^^^

Commit message formatting is significant.

Please see `How to contribute <https://github.com/saltstack-formulas/.github/blob/master/CONTRIBUTING.rst>`_ for more details.

pre-commit
^^^^^^^^^^

`pre-commit <https://pre-commit.com/>`_ is configured for this formula, which you may optionally use to ease the steps involved in submitting your changes.
First install  the ``pre-commit`` package manager using the appropriate `method <https://pre-commit.com/#installation>`_, then run ``bin/install-hooks`` and
now ``pre-commit`` will run automatically on each ``git commit``.

.. code-block:: console

  $ bin/install-hooks
  pre-commit installed at .git/hooks/pre-commit
  pre-commit installed at .git/hooks/commit-msg

State documentation
~~~~~~~~~~~~~~~~~~~
There is a script that semi-autodocuments available states: ``bin/slsdoc``.

If a ``.sls`` file begins with a Jinja comment, it will dump that into the docs. It can be configured differently depending on the formula. See the script source code for details currently.

This means if you feel a state should be documented, make sure to write a comment explaining it.

Testing
~~~~~~~

Linux testing is done with ``kitchen-salt``.

Requirements
^^^^^^^^^^^^

* Ruby
* Docker

.. code-block:: bash

  $ gem install bundler
  $ bundle install
  $ bin/kitchen test [platform]

Where ``[platform]`` is the platform name defined in ``kitchen.yml``,
e.g. ``debian-9-2019-2-py3``.

``bin/kitchen converge``
^^^^^^^^^^^^^^^^^^^^^^^^

Creates the docker instance and runs the ``tool_rust`` main state, ready for testing.

``bin/kitchen verify``
^^^^^^^^^^^^^^^^^^^^^^

Runs the ``inspec`` tests on the actual instance.

``bin/kitchen destroy``
^^^^^^^^^^^^^^^^^^^^^^^

Removes the docker instance.

``bin/kitchen test``
^^^^^^^^^^^^^^^^^^^^

Runs all of the stages above in one go: i.e. ``destroy`` + ``converge`` + ``verify`` + ``destroy``.

``bin/kitchen login``
^^^^^^^^^^^^^^^^^^^^^

Gives you SSH access to the instance for manual testing.
