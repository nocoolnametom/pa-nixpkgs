{ pkgs ? import <nixpkgs> { }
, php5Generic ? pkgs.callPackage ../build-support/php5Generic { }, ... }:

php5Generic {
  version = "5.6.36";
  sha256 = "0ahp9vk33dpsqgld0gg4npff67v0l39hs3wk5dm6h3lablzhwsk2";
}

