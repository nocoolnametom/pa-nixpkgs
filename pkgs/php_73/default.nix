{ pkgs ? import <nixpkgs> { }
, php7Generic ? pkgs.callPackage ../build-support/php7Generic { }, ... }:

php7Generic {
  version = "7.3.8";
  sha256 = "1xbndimrfamf97m3vln842g9w1ikq071gjfkk15ai7sx2wqccrnm";

  # https://bugs.php.net/bug.php?id=76826
  extraPatches = pkgs.lib.optional pkgs.stdenv.isDarwin ./darwin-isfinite.patch;
}
