{ pkgs ? import <nixpkgs> { }
, php7Generic ? pkgs.callPackage ../build-support/php7Generic { }, ... }:

php7Generic {
  version = "7.2.21";
  sha256 = "1vqldc2namfblwyv87fgpfffkjpzawfpcp48f40nfdl3pshq6c9l";

  # https://bugs.php.net/bug.php?id=76826
  extraPatches = pkgs.lib.optional pkgs.stdenv.isDarwin ./darwin-isfinite.patch;
}
