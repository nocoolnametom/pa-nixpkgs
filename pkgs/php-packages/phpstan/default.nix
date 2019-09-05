{ pkgs ? import <nixpkgs> { }, php' ? pkgs.callPackage ../../php72 { }, ... }:

let
  version = "0.11.12";
  sha256 = "12k74108f7a3k7ms8n4c625vpxrq75qamw1k1q09ndzmbn3i7c9b";
in pkgs.stdenv.mkDerivation rec {
  inherit version;
  pname = "phpstan";

  src = pkgs.fetchurl {
    inherit sha256;
    url =
      "https://github.com/phpstan/phpstan/releases/download/${version}/phpstan.phar";
  };

  phases = [ "installPhase" ];
  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    install -D $src $out/libexec/phpstan/phpstan.phar
    makeWrapper ${php'}/bin/php $out/bin/phpstan \
      --add-flags "$out/libexec/phpstan/phpstan.phar"
  '';
}
