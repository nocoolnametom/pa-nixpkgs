{ pkgs ? import <nixpkgs> { }
, php7Generic ? pkgs.callPackage ../build-support/php7Generic { }, ... }:

php7Generic {
  version = "7.1.30";
  sha256 = "1czcf5qwk727sdzx5n4wvsxvl50jx6d5x8ws1dqx46fa9xvm0j36";

  # https://bugs.php.net/bug.php?id=76826
  extraPatches = pkgs.lib.optional pkgs.stdenv.isDarwin ./darwin-isfinite.patch;
}
