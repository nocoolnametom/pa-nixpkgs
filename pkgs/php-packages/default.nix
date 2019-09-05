{ pkgs ? import <nixpkgs> { }, php'' ? pkgs.callPackage ../php_55 { }, ... }:

let
  self = php':
    let
      buildPecl = pkgs.callPackage ../build-support/build-pecl {
        php' =
          if (builtins.hasAttr "original" php') then php'.original else php';
        inherit (pkgs) stdenv autoreconfHook fetchurl re2c;
      };
      isPhp7 = pkgs.lib.versionAtLeast php'.version "7.0";
      isPhp71 = pkgs.lib.versionAtLeast php'.version "7.1";
      isPhp72 = pkgs.lib.versionAtLeast php'.version "7.2";
      isPhp73 = pkgs.lib.versionAtLeast php'.version "7.3";
    in (rec {
      overridePhp = self;
      box = pkgs.callPackage ./box { inherit php'; };
      composer = pkgs.callPackage ./composer { inherit php'; };
      php-cs-fixer = pkgs.callPackage ./php-cs-fixer { inherit php'; };
      php-parallel-lint = pkgs.callPackage ./php-parallel-lint {
        inherit php';
        inherit composer;
      };
      phpcbf = pkgs.callPackage ./phpcbf { inherit php'; };
      phpcs = pkgs.callPackage ./phpcs { inherit php'; };
      psysh = pkgs.callPackage ./psysh { inherit php'; };

      event = buildPecl rec {
        version = "2.5.3";
        pname = "event";

        sha256 = "12liry5ldvgwp1v1a6zgfq8w6iyyxmsdj4c71bp157nnf58cb8hb";

        configureFlags = [
          "--with-event-libevent-dir=${pkgs.libevent.dev}"
          "--with-event-core"
          "--with-event-extra"
          "--with-event-pthreads"
        ];
        nativeBuildInputs = [ pkgs.pkgconfig ];
        buildInputs = with pkgs; [ openssl libevent ];
      };

      imagick = buildPecl {
        pname = "imagick";
        version = "3.4.4";
        sha256 = "0xvhaqny1v796ywx83w7jyjyd0nrxkxf34w9zi8qc8aw8qbammcd";

        configureFlags = [ "--with-imagick=${pkgs.imagemagick.dev}" ];
        nativeBuildInputs = [ pkgs.pkgconfig ];
        buildInputs = [ (if isPhp73 then pkgs.pcre2 else pkgs.pcre) ];
      };

      pcs = buildPecl rec {
        pname = "pcs";
        version = "1.3.3";
        sha256 = "0d4p1gpl8gkzdiv860qzxfz250ryf0wmjgyc8qcaaqgkdyh5jy5p";
      };

    } // pkgs.lib.optionalAttrs (!isPhp7)
      (import ./php5-only.nix { inherit pkgs php' buildPecl; })
      // pkgs.lib.optionalAttrs (isPhp7) (import ./php70-and-up.nix {
        inherit pkgs php' buildPecl isPhp7 isPhp71 isPhp72 isPhp73;
      }) // pkgs.lib.optionalAttrs (isPhp7 && isPhp71)
      (import ./php71-and-up.nix { inherit pkgs php' buildPecl; })
      // pkgs.lib.optionalAttrs (isPhp7 && isPhp73)
      (import ./php73-and-up.nix { inherit pkgs php' buildPecl; }));
in self php''

