"""
cargo salt execution module
======================================================

Manage
"""

import re
from urllib.parse import parse_qs, urlparse

import salt.utils.platform
from salt.exceptions import CommandExecutionError

# import logging

# log = logging.getLogger(__name__)

__virtualname__ = "cargo"


def __virtual__():
    return __virtualname__


def _which(user=None):
    e = __salt__["cmd.run_stdout"]("command -v cargo", runas=user)
    # if e := __salt__["cmd.run_stdout"]("command -v cargo", runas=user):
    if e:
        return e
    if salt.utils.platform.is_darwin():
        for f in ["/opt/homebrew/bin", "/usr/local/bin"]:
            p = __salt__["cmd.run_stdout"](
                "test -s {}/cargo && echo {}/cargo".format(f, f), runas=user
            )
            # if p := __salt__["cmd.run_stdout"]("test -s {}/cargo && echo {}/cargo".format(f, f) , runas=user):
            if p:
                return p
    raise CommandExecutionError("Could not find cargo executable.")


def is_installed(name, root=None, user=None, allow_git=True):
    """
    Checks whether a program with this name is installed by cargo.

    CLI Example:

    .. code-block:: bash

        salt '*' cargo.is_installed broot user=user

    name
        The name of the program to check.

    root:
        Use this path as root folder for check. If you installed it
        somewhere else, the check will fail. Defaults to cargo's default
        ($CARGO_INSTALL_ROOT > install.root config val > $CARGO_HOME > $HOME/.cargo)

    user
        The username to check for. Defaults to salt user.

    allow_git
        Whether to check for git sources as names as well.
        This does not differentiate between branches/revs/tags.
        Defaults to True.
    """

    installed = list_installed(root, user=user)

    if name in installed:
        return True

    if not allow_git:
        return False

    parsed = urlparse(name)

    if parsed.netloc and parsed.path:
        repo = parsed.netloc + parsed.path

        return bool([x for x in installed if installed[x]["repo"] == repo])

    return False


def is_latest(name, root=None, user=None):
    """
    Checks whether the program is at its latest crates.io version.

    CLI Example:

    .. code-block:: bash

        salt '*' cargo.is_latest starship user=user

    name
        The name of the program to check.

    root:
        Use this path as root folder for check. If you installed it
        somewhere else, the check will fail. Defaults to cargo's default
        ($CARGO_INSTALL_ROOT > install.root config val > $CARGO_HOME > $HOME/.cargo)

    user
        The username to check for. Defaults to salt user.
    """

    installed = list_installed(root, user)

    if name not in installed:
        raise CommandExecutionError(
            "{} is not installed with cargo for user {}.".format(name, user)
        )
    elif installed[name]["git"]:
        raise CommandExecutionError(
            "{} is not sourced from crates.io for user {}. Version checking is currently not implemented for this scenario.".format(
                name, user
            )
        )

    return latest_version(name, user) == installed[name]["version"]


def latest_version(name, user=None):
    """
    Returns the program's latest crates.io version.

    CLI Example:

    .. code-block:: bash

        salt '*' cargo.latest_version du-dust user=user

    name
        The name of the program to get the version for.

    user
        The username to check for. Defaults to salt user.
    """

    e = _which(user)

    out = __salt__["cmd.run_stdout"]("{} search {}".format(e, name), runas=user)

    # no multiline to use the first search result only
    return re.match(r"^[^\d]*([\d\.]*)", out).group(1)


def install(
    name,
    version=None,
    locked=True,
    root=None,
    force=False,
    git=None,
    path=None,
    branch=None,
    tag=None,
    rev=None,
    user=None,
):
    """
    Installs rust binary with cargo.

    CLI Example:

    .. code-block:: bash

        salt '*' cargo.install flavours user=user

    name
        The name of the program to install. Irrelevant when using git.
        For git, the effective package name is defined in ``Cargo.toml`` under ``[package]``.
        You will need to use it for other operations.

    version:
        If you want to install a specific version and are installing from
        crates.io (default), specify here.

    locked:
        Use the package's lockfile when pulling dependencies. Defaults to True.

    root:
        Use this path as root folder for installation. Defaults to cargo's default
        ($CARGO_INSTALL_ROOT > install.root config val > $CARGO_HOME > $HOME/.cargo)

    force:
        Force installation, even if the package is up to date.

    git:
        Install from a git repository, e.g. https://github.com/starship/starship

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

    e = _which(user)
    flags = []

    if locked:
        flags.append("--locked")
    if root:
        flags.append("--root={}".format(root))
    if force:
        flags.append("--force")
    if git:
        flags.append("--git=" + git)
        if branch:
            flags.append("--branch=" + branch)
        elif tag:
            flags.append("--tag=" + tag)
        elif rev:
            flags.append("--rev=" + rev)
    if path:
        flags.append("--path=" + path)
    if not git and not path and version:
        flags.append("--vers=" + version)

    if git:
        return not __salt__["cmd.retcode"](
            "{} install {}".format(e, name, " ".join(flags)), runas=user
        )

    # cmd.retcode returns shell-style: 0 for success, >0 for failure
    return not __salt__["cmd.retcode"](
        "{} install '{}' {}".format(e, name, " ".join(flags)), runas=user
    )


def remove(name, root=None, user=None):
    """
    Uninstalls rust binary with cargo.

    CLI Example:

    .. code-block:: bash

        salt '*' cargo.remove starship user=user

    name
        The name of the program to uninstall.

    root:
        Use this path as root folder for uninstallation. Defaults to cargo's default
        ($CARGO_INSTALL_ROOT > install.root config val > $CARGO_HOME > $HOME/.cargo)

    user
        The username to uninstall the program for. Defaults to salt user.
    """

    if not is_installed(name, root, user, allow_git=False):
        raise CommandExecutionError(
            "{} is not installed with cargo for user {}.".format(name, user)
        )
    flags = []
    # if multiple versions of the same binary were installed, this uninstalls only the one in $root/bin
    if root:
        flags.append("--root=" + root)

    e = _which(user)

    return not __salt__["cmd.retcode"](
        "{} uninstall '{}' {}".format(e, name, " ".join(flags)), runas=user
    )


def upgrade(name, locked=True, root=None, user=None):
    """
    Upgrades rust binary from crates.io with cargo. This is mostly a wrapper
    around install(force=True) with checks. If you want to upgrade from another
    source, use install(force=True).

    CLI Example:

    .. code-block:: bash

        salt '*' cargo.upgrade broot user=user

    name
        The name of the program to upgrade.

    locked:
        Use the package's lockfile when pulling dependencies. Defaults to True.

    root:
        Use this path as root folder for upgrading. Defaults to cargo's default
        ($CARGO_INSTALL_ROOT > install.root config val > $CARGO_HOME > $HOME/.cargo)
        If the program cannot be found there, will raise an error.

    user
        The username to upgrade the program for. Defaults to salt user.
    """

    if not is_installed(name, root, user, allow_git=False):
        raise CommandExecutionError(
            "{} is not installed with cargo for user {}.".format(name, user)
        )

    if is_latest(name, root, user):
        raise CommandExecutionError(
            "{} is already the latest version for user {}.".format(name, user)
        )

    return install(name, locked, root, user=user)


def reinstall(name, locked=True, root=None, user=None):
    """
    Reinstalls rust binary from crates.io with cargo. This is mostly a wrapper
    around install(force=True) with checks. If you want to reinstall from another
    source, use install(force=True).

    CLI Example:

    .. code-block:: bash

        salt '*' cargo.reinstall broot user=user

    name
        The name of the program to reinstall.

    locked:
        Use the package's lockfile when pulling dependencies. Defaults to True.

    root:
        Use this path as root folder for reinstallation. Defaults to cargo's default
        ($CARGO_INSTALL_ROOT > install.root config val > $CARGO_HOME > $HOME/.cargo)
        If the program cannot be found there, will raise an error.

    user
        The username to reinstall the program for. Defaults to salt user.
    """

    if not is_installed(name, root, user):
        raise CommandExecutionError(
            "{} is not installed with cargo for user {}.".format(name, user)
        )

    return install(name, locked, root, force=True, user=user)


def list_installed(root=None, user=None):
    """
    Returns a dictionary of installed crates.

    Example output:

    .. code-block:: yaml

        rbw:
            branch: ''
            commit: ''
            git: False
            repo: ''
            rev: ''
            source: crates.io/crates/rbw
            version: 0.5.2
        starship:
            branch: release-please
            commit: ebb86367
            git: True
            repo: github.com/starship/starship
            rev: ''
            source: https://github.com/starship/starship?branch=release-please#ebb86367
            version: 1.5.4

    CLI Example:

    .. code-block:: bash

        salt '*' cargo.list_installed user=user

    root:
        Use this path as root folder for the listing. If you installed it
        somewhere else, the check will fail. Defaults to cargo's default
        ($CARGO_INSTALL_ROOT > install.root config val > $CARGO_HOME > $HOME/.cargo)

    user
        The username to list for. Defaults to salt user.
    """

    e = _which(user)

    out = __salt__["cmd.run_stdout"](
        "{} install --list".format(e), raise_err=True, runas=user
    )

    if out:
        return _parse(out)
    return {}


def _parse(installed):
    res = re.findall(r"(?m)^([^\s]+)\ v([\d\.]+)(?:\ \((.*)\))?:$", installed)
    ret = {}

    for name, version, source in res:
        branch = commit = rev = repo = ""
        git = False

        # This works for Github specifically, not sure
        # about other sources. @TODO
        if source:
            parsed = urlparse(source)
            commit = parsed.fragment
            parsed_q = parse_qs(parsed.query)
            repo = parsed.netloc + parsed.path
            rev = parsed_q.get("rev", [""])[0]
            branch = parsed_q.get("branch", [""])[0]
            git = True
        else:
            source = "crates.io/crates/" + name

        ret[name] = {
            "branch": branch,
            "commit": commit,
            "git": git,
            "rev": rev,
            "repo": repo,
            "source": source,
            "version": version,
        }

    return ret
