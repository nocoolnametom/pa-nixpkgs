{ pkgs ? import <nixpkgs> { }
, php7Generic ? pkgs.callPackage ../build-support/php7Generic { }, ... }:

php7Generic {
  version = "7.0.30";
  sha256 = "0l0bhnlgxmfl7mrdykmxfl53simxsksdcnbg5ymqz6r31i03hgr1";
}
