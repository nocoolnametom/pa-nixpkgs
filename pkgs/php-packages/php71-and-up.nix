{ pkgs, buildPecl, php' }:

rec {
  phpstan = pkgs.callPackage ./phpstan { inherit php'; };
}
