{ pkgs ? import <nixpkgs> { }, ... }:

phpPackage: configIni:
pkgs.stdenv.mkDerivation rec {
  name = "wrapped-php";
  version = phpPackage.version;
  original = phpPackage;
  phases = [ "installPhase" ];
  buildInputs = [ pkgs.makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    ln -s ${phpPackage}/bin/php $out/bin/php
    wrapProgram $out/bin/php --add-flags "-c ${configIni}"
  '';
}

