{ pkgs ? import <nixpkgs> { }, php' ? pkgs.callPackage ../../php_72 { }, ... }:

let
  version = "0.9.9";
  sha256 = "0knbib0afwq2z5fc639ns43x8pi3kmp85y13bkcl00dhvf46yinw";
in pkgs.stdenv.mkDerivation rec {
  inherit version;
  pname = "psysh";

  src = pkgs.fetchurl {
    inherit sha256;
    url =
      "https://github.com/bobthecow/psysh/releases/download/v${version}/psysh-v${version}.tar.gz";
  };

  phases = [ "installPhase" ];
  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    tar -xzf $src -C $out/bin
    chmod +x $out/bin/psysh
    wrapProgram $out/bin/psysh
  '';
}
