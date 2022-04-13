"""
cargo salt state module
======================================================

"""

# import logging
import salt.exceptions

# import salt.utils.platform

# log = logging.getLogger(__name__)

__virtualname__ = "cargo"


def __virtual__():
    return __virtualname__


def installed(
    name,
    version=None,
    locked=True,
    root=None,
    force=False,
    git=False,
    path=None,
    branch=None,
    tag=None,
    rev=None,
    user=None,
):
    """
    Makes sure rust binary is installed with cargo.

    name
        The name of the program to install, if not already installed.
        For git sources, this is the repository URI, e.g. https://github.com/starship/starship

    version:
        If you want to install a specific version and are installing from
        crates.io (default), specify here. Currently, the program will
        NOT be reinstalled with the specified version if it is already
        found. 'latest' or None for latest version.

    locked:
        Use the package's lockfile when pulling dependencies. Defaults to True.

    root:
        Use this path as root folder for installation. Defaults to cargo's default
        ($CARGO_INSTALL_ROOT > install.root config val > $CARGO_HOME > $HOME/.cargo)

    force:
        Force installation, even if the package is up to date.

    git:
        Whether the name indicates a git repo URI. Defaults to False.

    path:
        Install from a local filesystem path.

    branch:
        When installing from a git repository, install from this branch.

    tag:
        When installing from a git repository, install from this tag.

    rev:
        When installing from a git repository, install from this specific commit.

    user
        The username to install the program for. Defaults to salt user.
    """

    ret = {"name": name, "result": True, "comment": "", "changes": {}}

    if version == "latest":
        version = None

    git = name if git else None

    try:
        if __salt__["cargo.is_installed"](name, root, user):
            ret["comment"] = "Program is already installed with cargo."
        elif __opts__["test"]:
            ret["result"] = None
            ret[
                "comment"
            ] = "Program '{}' would have been installed for user '{}' in '{}'.".format(
                name, user, root
            )
            ret["changes"] = {"installed": name}
        elif __salt__["cargo.install"](
            name, version, locked, root, force, git, path, branch, tag, rev, user
        ):
            ret["comment"] = "Program '{}' was installed for user '{}' in '{}'.".format(
                name, user, root
            )
            ret["changes"] = {"installed": name}
        else:
            ret["result"] = False
            ret["comment"] = "Something went wrong while calling cargo."
    except salt.exceptions.CommandExecutionError as e:
        ret["result"] = False
        ret["comment"] = str(e)

    return ret


def latest(name, locked=True, root=None, user=None):
    """
    Makes sure program is installed with cargo and is up to date. This works
    for installation from crates.io. For git/path sources, use installed(force=True).
    @TODO: check git repositories for updates?

    name
        The name of the program to upgrade.

    locked:
        Use the package's lockfile when pulling dependencies. Defaults to True.

    root:
        Use this path as root folder for upgrading. Defaults to cargo's default
        ($CARGO_INSTALL_ROOT > install.root config val > $CARGO_HOME > $HOME/.cargo)

    user
        The username to upgrade the program for. Defaults to salt user.
    """

    ret = {"name": name, "result": True, "comment": "", "changes": {}}

    try:
        if __salt__["cargo.is_installed"](name, root, user, allow_git=False):
            if __salt["cargo.is_latest"](name, root, user):
                ret[
                    "comment"
                ] = "Program '{}' is already at its latest version in '{}' from crates.io for user '{}'.".format(
                    name, root, user
                )
            elif __opts__["test"]:
                ret["result"] = None
                ret[
                    "comment"
                ] = "Program '{}' would have been upgraded for user '{}'.".format(
                    name, user
                )
                ret["changes"] = {"installed": name}
            elif __salt__["cargo.upgrade"](name, locked, root, user):
                ret["comment"] = "Program '{}' was upgraded for user '{}'.".format(
                    name, user
                )
                ret["changes"] = {"upgraded": name}
            else:
                ret["result"] = False
                ret["comment"] = "Something went wrong while calling mas."
        elif __opts__["test"]:
            ret["result"] = None
            ret[
                "comment"
            ] = "Program '{}' would have been installed for user '{}' in '{}'.".format(
                name, user, root
            )
            ret["changes"] = {"installed": name}
        elif __salt__["cargo.install"](name, locked=locked, root=root, user=user):
            ret["comment"] = "Program '{}' was installed for user '{}' in '{}'.".format(
                name, user, root
            )
            ret["changes"] = {"installed": name}
        else:
            ret["result"] = False
            ret["comment"] = "Something went wrong while calling cargo."
        return ret

    except salt.exceptions.CommandExecutionError as e:
        ret["result"] = False
        ret["comment"] = str(e)

    return ret


def absent(name, root=None, user=None):
    """
    Makes sure cargo installation of program is absent.

    name
        The name of the program to remove, if installed.

    root:
        Use this path as root folder for uninstallation. Defaults to cargo's default
        ($CARGO_INSTALL_ROOT > install.root config val > $CARGO_HOME > $HOME/.cargo)

    user
        The username to uninstall the program for. Defaults to salt user.
    """
    ret = {"name": name, "result": True, "comment": "", "changes": {}}

    try:
        if not __salt__["cargo.is_installed"](name, root, user):
            ret["comment"] = "Program is already absent from cargo."
        elif __opts__["test"]:
            ret["result"] = None
            ret[
                "comment"
            ] = "Program '{}' in '{}' would have been removed for user '{}'.".format(
                name, root, user
            )
            ret["changes"] = {"installed": name}
        elif __salt__["cargo.remove"](name, root, user):
            ret["comment"] = "Program '{}' in '{}' was removed for user '{}'.".format(
                name, root, user
            )
            ret["changes"] = {"installed": name}
        else:
            ret["result"] = False
            ret["comment"] = "Something went wrong while calling cargo."
    except salt.exceptions.CommandExecutionError as e:
        ret["result"] = False
        ret["comment"] = str(e)

    return ret
