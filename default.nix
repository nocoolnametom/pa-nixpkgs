{ pkgs ? import <nixpkgs> { } }:

let
  php5Generic = pkgs.callPackage ./pkgs/build-support/php5Generic { };
  php7Generic = pkgs.callPackage ./pkgs/build-support/php7Generic { };
in rec {
  wrapPhpWithConfig = pkgs.callPackage ./pkgs/wrapPhpWithConfig { };

  php_55 = pkgs.callPackage ./pkgs/php_55 { inherit php5Generic; };
  php_55Packages = pkgs.callPackage ./pkgs/php-packages { php'' = php_55; };

  php_56 = pkgs.callPackage ./pkgs/php_56 { inherit php5Generic; };
  php_56Packages = pkgs.callPackage ./pkgs/php-packages { php'' = php_56; };

  php_70 = pkgs.callPackage ./pkgs/php_70 { inherit php7Generic; };
  php_70Packages = pkgs.callPackage ./pkgs/php-packages { php'' = php_70; };

  php_71 = pkgs.callPackage ./pkgs/php_71 { inherit php7Generic; };
  php_71Packages = pkgs.callPackage ./pkgs/php-packages { php'' = php_71; };

  php_72 = pkgs.callPackage ./pkgs/php_72 { inherit php7Generic; };
  php_72Packages = pkgs.callPackage ./pkgs/php-packages { php'' = php_72; };

  php_73 = pkgs.callPackage ./pkgs/php_73 { inherit php7Generic; };
  php_73Packages = pkgs.callPackage ./pkgs/php-packages { php'' = php_73; };

  # An example of overriding a collection of packages with a particular PHP version
  # php_70_with_config = wrapPhpWithConfig php_70 "foobar";
  # php_70_with_config_composer = (php_56Packages.overridePhp php_70_with_config).composer;

  # Beta2 doesn't currently build without issues
  # php_74 = pkgs.callPackage ./pkgs/php_74 { inherit php7Generic; };
  # php_74Packages = pkgs.callPackage ./pkgs/php-packages { php'' = php_74; };
}
