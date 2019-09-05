{ pkgs ? import <nixpkgs> { }, php' ? pkgs.callPackage ../../php_72 { }, ... }:

let
  version = "3.4.2";
  sha256 = "08s47r8i5dyjivk1q3nhrz40n6fx3zghrn5irsxfnx5nj9pb7ffp";
in pkgs.stdenv.mkDerivation rec {
  inherit version;
  pname = "phpcbf";

  src = pkgs.fetchurl {
    inherit sha256;
    url =
      "https://github.com/squizlabs/PHP_CodeSniffer/releases/download/${version}/phpcbf.phar";
  };

  phases = [ "installPhase" ];
  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    install -D $src $out/libexec/phpcbf/phpcbf.phar
    makeWrapper ${php'}/bin/php $out/bin/phpcbf \
      --add-flags "$out/libexec/phpcbf/phpcbf.phar"
  '';
}
