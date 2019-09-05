Phthalic Anhydride Nix Packages
=================================

This project provides the basic packages for using old versions of PHP
and other tools using the [Nix][] package manager together with the Nix libraries found in [Nixpkgs][].

Installation
------------

1.  Make sure you have a working Nix installation. If you are not
    using NixOS then you may here have to run

    ```console
    $ mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/$USER
    ```

    since Home Manager uses these directories to manage your profile
    generations. On NixOS these should already be available.

    Also make sure that your user is able to build and install Nix
    packages. For example, you should be able to successfully run a
    command like `nix-instantiate '<nixpkgs>' -A hello` without having
    to switch to the root user. For a multi-user install of Nix this
    means that your user must be covered by the
    [`allowed-users`][nixAllowedUsers] Nix option. On NixOS you can
    control this option using the
    [`nix.allowedUsers`][nixosAllowedUsers] system option.

2.  Add the appropriate Phthalic Anhydride channel.  Typically this is

    ```console
    $ nix-channel --add https://github.com/nocoolnametom/pa-nixpkgs/archive/master.tar.gz pa-nixpkgs
    $ nix-channel --update
    ```

    On NixOS you may need to log out and back in for the channel to
    become available. On non-NixOS you may have to add

    ```shell
    export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
    ```

    to your shell (see [nix#2033](https://github.com/NixOS/nix/issues/2033)).

Usage
-----

Use the channel name in your initial derivation requirements either as
a parameter:

```nix
# default.nix
{ pkgs ? import <nixpkgs> {}, paPkgs ? import <pa-nixpkgs> {}, ...}:

# Build your derivation...
```

Or as a `with` declaration:

```nix
# default.nix
with import <nixpkgs> {};
with import <pa-nixpkgs> {};

# Build your derivation...
```

Packages
--------

The current packages available are:

 * `paPkgs.php_55`
 * `paPkgs.php_56`
 * `paPkgs.php_70`
 * `paPkgs.php_71`
 * `paPkgs.php_72`
 * `paPkgs.php_73`

If you need a specific version of PHP you can build a package using the
generic builders:

 * `php5Generic`
 * `php7Generic`

```nix
# Example
php56 = paPkgs.php5Generic {
  version = "5.5.35";
  sha256 = "1msqh8ii0qwzzcwlwn8f493x2r3hy2djzrrwd5jgs87893b8sr1d";
};
```

Adding a PHP Configuration to the PHP package:

 * `wrapPhpWithConfig`

```nix
# Example - Note that this also uses the packages override as described
# below because you're altering the PHP package
myPhpConfig = pkgs.writeText "env_config.ini" ''
  date.timezone = America/Los_Angeles
  zend_extension = ${paPkgs.php_71Packages.xdebug}/lib/php/extensions/xdebug.so
  xdebug.remote_enable = 1
  xdebug.remote_autostart = 1
''
myPhp = paPkgs.wrapPhpWithConfig php71 myPhpConfig;
```

There are also package groups:

 * `paPkgs.php_55Packages`
 * `paPkgs.php_56Packages`
 * `paPkgs.php_70Packages`
 * `paPkgs.php_71Packages`
 * `paPkgs.php_72Packages`
 * `paPkgs.php_73Packages`

Make sure you inject your PHP package into the package groups via the
`overridePhp` attribute, even if you only updated it with an INI config:

```nix
# Example
myPhpConfig = pkgs.writeText "env_config.ini" ''
  date.timezone = America/Los_Angeles
  zend_extension = ${myPhpPackages.xdebug}/lib/php/extensions/xdebug.so
  xdebug.remote_enable = 1
  xdebug.remote_autostart = 1
''
myPhp = paPkgs.wrapPhpWithConfig php71 myPhpConfig;
myPhpPackages = paPkgs.php_71Packages.overridePhp myPhp;
```

Those are the basics so far.

[Nix]: https://nixos.org/nix/
[NixOS]: https://nixos.org/
[Nixpkgs]: https://nixos.org/nixpkgs/
[nixAllowedUsers]: https://nixos.org/nix/manual/#conf-allowed-users
[nixosAllowedUsers]: https://nixos.org/nixos/manual/options.html#opt-nix.allowedUsers

