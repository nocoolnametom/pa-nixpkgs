{ pkgs ? import <nixpkgs> { }, php' ? pkgs.callPackage ../../php_72 { }, ... }:

let
  version = "1.9.0";
  sha256 = "0x88bin1c749ajymz2cqjx8660a3wxvndpv4xr6w3pib16fzdpy9";
in pkgs.stdenv.mkDerivation rec {
  inherit version;
  name = "composer-${version}";
  src = pkgs.fetchurl {
    inherit sha256;
    url = "https://getcomposer.org/download/${version}/composer.phar";
  };
  unpackPhase = ":";
  buildInputs = [ pkgs.makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    install -D $src $out/libexec/composer/composer.phar
    makeWrapper ${php'}/bin/php $out/bin/composer \
      --add-flags "$out/libexec/composer/composer.phar"
  '';
}
