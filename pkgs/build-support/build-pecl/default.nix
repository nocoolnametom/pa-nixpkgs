{ pkgs ? import <nixpkgs> { }, stdenv ? pkgs.stdenv
, php' ? pkgs.callPackage ../../php_72 { }, autoreconfHook ? pkgs.autoreconfHook
, fetchurl ? pkgs.fetchurl, re2c ? pkgs.re2c }:

{ pname, version, buildInputs ? [ ], nativeBuildInputs ? [ ], makeFlags ? [ ]
, src ? fetchurl {
  url = "http://pecl.php.net/get/${pname}-${version}.tgz";
  inherit (args) sha256;
}, ... }@args:

stdenv.mkDerivation (args // {
  name = "php-${pname}-${version}";

  inherit src;

  nativeBuildInputs = [ autoreconfHook re2c ] ++ nativeBuildInputs;
  buildInputs = [ php' ] ++ buildInputs;

  makeFlags = [ "EXTENSION_DIR=$(out)/lib/php/extensions" ] ++ makeFlags;

  autoreconfPhase = "phpize";
})
