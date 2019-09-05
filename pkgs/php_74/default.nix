{ pkgs ? import <nixpkgs> { }
, php7Generic ? pkgs.callPackage ../build-support/php7Generic { }, ... }:

php7Generic rec {
  version = "7.4.0beta2";
  sha256 = "0pa9avnxcs6pkbisvhbsj0wz3xv8k0yx54a0f9sazjjidhxqw4rf";

  # The URL is overwritten only for the beta and RC versions, remove when stable
  url = "https://downloads.php.net/~derick/php-${version}.tar.bz2";

  # https://bugs.php.net/bug.php?id=76826
  extraPatches = pkgs.lib.optional pkgs.stdenv.isDarwin ./darwin-isfinite.patch;
}
