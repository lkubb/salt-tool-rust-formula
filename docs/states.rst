Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``tool_rust``
~~~~~~~~~~~~~
*Meta-state*.

Performs all operations described in this formula according to the specified configuration.


``tool_rust.package``
~~~~~~~~~~~~~~~~~~~~~
Installs the Rust package only.


``tool_rust.package.asdf``
~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_rust.package.pkg``
~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_rust.package.web``
~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_rust.xdg``
~~~~~~~~~~~~~~~~~
Ensures Rust adheres to the XDG spec
as best as possible for all managed users.
Has a dependency on `tool_rust.package`_.


``tool_rust.env_vars``
~~~~~~~~~~~~~~~~~~~~~~



``tool_rust.config``
~~~~~~~~~~~~~~~~~~~~
Manages the Rust package configuration by

* recursively syncing from a dotfiles repo

Has a dependency on `tool_rust.package`_.


``tool_rust.crates``
~~~~~~~~~~~~~~~~~~~~



``tool_rust.clean``
~~~~~~~~~~~~~~~~~~~
*Meta-state*.

Undoes everything performed in the ``tool_rust`` meta-state
in reverse order.


``tool_rust.package.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~
Removes the Rust package.
Has a dependency on `tool_rust.config.clean`_.


``tool_rust.package.asdf.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_rust.package.web.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_rust.xdg.clean``
~~~~~~~~~~~~~~~~~~~~~~~



``tool_rust.env_vars.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_rust.config.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~
Removes the configuration of the Rust package.


``tool_rust.crates.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~



