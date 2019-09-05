{ pkgs ? import <nixpkgs> { }, php' ? pkgs.callPackage ../../php_72 { }, ... }:

let
  version = "3.4.2";
  sha256 = "0hk9w5kn72z9xhswfmxilb2wk96vy07z4a1pwrpspjlr23aajrk9";
in pkgs.stdenv.mkDerivation rec {
  inherit version;
  name = "phpcs-${version}";
  src = pkgs.fetchurl {
    inherit sha256;
    url =
      "https://github.com/squizlabs/PHP_CodeSniffer/releases/download/${version}/phpcs.phar";
  };
  unpackPhase = ":";
  buildInputs = [ pkgs.makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    install -D $src $out/libexec/phpcs/phpcs.phar
    makeWrapper ${php'}/bin/php $out/bin/phpcs \
      --add-flags "$out/libexec/phpcs/phpcs.phar"
  '';
}
