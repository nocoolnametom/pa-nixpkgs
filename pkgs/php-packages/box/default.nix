{ pkgs ? import <nixpkgs> { }, php' ? pkgs.callPackage ../../php72 { }, ... }:

let
  version = "2.7.5";
  sha256 = "1zmxdadrv0i2l8cz7xb38gnfmfyljpsaz2nnkjzqzksdmncbgd18";
in pkgs.stdenv.mkDerivation rec {
  inherit version;
  pname = "box";

  src = pkgs.fetchurl {
    url =
      "https://github.com/box-project/box2/releases/download/${version}/box-${version}.phar";
    inherit sha256;
  };

  phases = [ "installPhase" ];
  buildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    install -D $src $out/libexec/box/box.phar
    makeWrapper ${php'}/bin/php $out/bin/box \
      --add-flags "-d phar.readonly=0 $out/libexec/box/box.phar"
  '';
}
