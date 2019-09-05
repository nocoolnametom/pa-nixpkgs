{ pkgs ? import <nixpkgs> { }, php' ? pkgs.callPackage ../../php_72 { }, ... }:

let
  version = "2.15.1";
  sha256 = "0qbqdki6vj8bgj5m2k4mi0qgj17r6s2v2q7yc30hhgvksf7vamlc";
in pkgs.stdenv.mkDerivation rec {
  inherit version;
  pname = "php-cs-fixer";

  src = pkgs.fetchurl {
    url =
      "https://github.com/FriendsOfPHP/PHP-CS-Fixer/releases/download/v${version}/php-cs-fixer.phar";
    inherit sha256;
  };

  phases = [ "installPhase" ];
  buildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    install -D $src $out/libexec/php-cs-fixer/php-cs-fixer.phar
    makeWrapper ${php'}/bin/php $out/bin/php-cs-fixer \
      --add-flags "$out/libexec/php-cs-fixer/php-cs-fixer.phar"
  '';
}
