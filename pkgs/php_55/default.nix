{ pkgs ? import <nixpkgs> { }
, php5Generic ? pkgs.callPackage ../build-support/php5Generic { }, ... }:

php5Generic {
  version = "5.5.37";
  sha256 = "d2380ebe46caf17f2c4cd055867d00a82e6702dc5f62dc29ce864a5742905d88";
}

