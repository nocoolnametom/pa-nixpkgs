{ pkgs ? import <nixpkgs> { }, box ? pkgs.callPackage ../box { inherit php'; }
, composer ? pkgs.callPackage ../composer { inherit php'; }
, php' ? pkgs.callPackage ../../php_72 { }, ... }:

let
  version = "1.0.0";
  sha256 = "16nv8yyk2z3l213dg067l6di4pigg5rd8yswr5xgd18jwbys2vnw";
in pkgs.stdenv.mkDerivation rec {
  inherit version;
  pname = "php-parallel-lint";

  src = pkgs.fetchFromGitHub {
    inherit sha256;
    owner = "JakubOnderka";
    repo = "PHP-Parallel-Lint";
    rev = "v${version}";
  };

  buildInputs = [ pkgs.makeWrapper composer box ];

  buildPhase = ''
    composer dump-autoload
    box build
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -D parallel-lint.phar $out/libexec/php-parallel-lint/php-parallel-lint.phar
    makeWrapper ${php'}/bin/php $out/bin/php-parallel-lint \
      --add-flags "$out/libexec/php-parallel-lint/php-parallel-lint.phar"
  '';
}
