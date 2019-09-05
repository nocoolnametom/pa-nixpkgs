{ pkgs, buildPecl, isPhp73, isPhp72, isPhp71, isPhp7, php' }:

rec {
  pdo_sqlsrv = buildPecl rec {
    version = "5.6.1";
    pname = "pdo_sqlsrv";

    sha256 = "02ill1iqffa5fha9iz4y91823scml24ikfk8pn90jyycfwv07x6a";

    buildInputs = [ pkgs.unixODBC ];
  };

  igbinary = buildPecl {
    pname = "igbinary";
    version = "3.0.1";
    sha256 = "1w8jmf1qpggdvq0ndfi86n7i7cqgh1s8q6hys2lijvi37rzn0nar";

    configureFlags = [ "--enable-igbinary" ];
    makeFlags = [ "phpincludedir=$(dev)/include" ];
    outputs = [ "out" "dev" ];
  };

  apcu = buildPecl rec {
    pname = "apcu";
    version = "5.1.17";
    sha256 = "14y7alvj5q17q1b544bxidavkn6i40cjbq2nv1m0k70ai5vv84bb";

    buildInputs = [ (if isPhp73 then pkgs.pcre2 else pkgs.pcre) ];
    doCheck = true;
    checkTarget = "test";
    checkFlagsArray = [ "REPORT_EXIT_STATUS=1" "NO_INTERACTION=1" ];
    makeFlags = [ "phpincludedir=$(dev)/include" ];
    outputs = [ "out" "dev" ];
  };

  apcu_bc = buildPecl {
    pname = "apcu_bc";
    version = "1.0.5";
    sha256 = "0ma00syhk2ps9k9p02jz7rii6x3i2p986il23703zz5npd6y9n20";
    buildInputs = [ apcu (if isPhp73 then pkgs.pcre2 else pkgs.pcre) ];
  };

  ast = buildPecl {
    pname = "ast";
    version = "1.0.3";
    sha256 = "1sk9bkyw3ck9jgvlazxx8zl2nv6lc0gq66v1rfcby9v0zyydb7xr";
  };

  php_excel = buildPecl rec {
    pname = "php_excel";
    version = "1.0.2";

    buildInputs = [ pkgs.libxl ];

    src = pkgs.fetchurl {
      url =
        "https://github.com/iliaal/php_excel/releases/download/Excel-1.0.2-PHP7/excel-${version}-php7.tgz";
      sha256 = "0dpvih9gpiyh1ml22zi7hi6kslkilzby00z1p8x248idylldzs2n";
    };

    configureFlags = [
      "--with-excel"
      "--with-libxl-incdir=${pkgs.libxl}/include_c"
      "--with-libxl-libdir=${pkgs.libxl}/lib"
    ];
  };

  memcached = buildPecl rec {
    pname = "memcached";
    version = "3.1.3";
    src = pkgs.fetchgit {
      url = "https://github.com/php-memcached-dev/php-memcached";
      rev = "v${version}";
      sha256 = "1w9g8k7bmq3nbzskskpsr5632gh9q75nqy7nkjdzgs17klq9khjk";
    };

    configureFlags = [
      "--with-zlib-dir=${pkgs.zlib.dev}"
      "--with-libmemcached-dir=${pkgs.libmemcached}"
    ];
    nativeBuildInputs = [ pkgs.pkgconfig ];
    buildInputs = with pkgs; [ cyrus_sasl zlib ];
  };

  mongodb = buildPecl {
    pname = "mongodb";
    version = "1.5.5";

    sha256 = "0gpywk3wkimjrva1p95a7abvl3s8yccalf6yimn3nbkpvn2kknm6";

    nativeBuildInputs = [ pkgs.pkgconfig ];
    buildInputs = with pkgs;
      [ cyrus_sasl icu openssl snappy zlib (if isPhp73 then pcre2 else pcre) ]
      ++ lib.optional (pkgs.stdenv.isDarwin)
      pkgs.darwin.apple_sdk.frameworks.Security;
  };

  sqlsrv = buildPecl rec {
    version = "5.6.1";
    pname = "sqlsrv";

    sha256 = "0ial621zxn9zvjh7k1h755sm2lc9aafc389yxksqcxcmm7kqmd0a";

    buildInputs = [ pkgs.unixODBC ];
  };

  protobuf = buildPecl rec {
    version = "3.9.0";
    pname = "protobuf";

    sha256 = "1pyfxrfdbzzg5al4byyazdrvy7yad13zwq7papbb2d8gkvc3f3kh";

    buildInputs = with pkgs; [ (if isPhp73 then pcre2 else pcre) ];
  };

  xdebug = buildPecl rec {
    pname = "xdebug";
    version = "2.7.1";
    sha256 = "1hr4gy87a3gp682ggwp831xk1fxasil9wan8cxv23q3m752x3sdp";

    doCheck = true;
    checkTarget = "test";
  };

  yaml = buildPecl rec {
    pname = "yaml";
    version = "2.0.4";
    sha256 = "1036zhc5yskdfymyk8jhwc34kvkvsn5kaf50336153v4dqwb11lp";

    configureFlags = [ "--with-yaml=${pkgs.libyaml}" ];
    nativeBuildInputs = [ pkgs.pkgconfig ];
  };

  redis = buildPecl rec {
    pname = "redis";
    version = "5.0.2";
    sha256 = "0b5pw17lzqknhijfymksvf8fm1zilppr97ypb31n599jw3mxf62f";
  };

  mailparse = buildPecl {
    pname = "mailparse";
    version = "3.0.3";
    sha256 = "00nk14jbdbln93mx3ag691avc11ff94hkadrcv5pn51c6ihsxbmz";
  };
} // pkgs.lib.optionalAttrs (!isPhp73) rec {
  pinba = buildPecl rec {
    version = "1.1.1";
    pname = "pinba";

    src = pkgs.fetchFromGitHub {
      owner = "tony2001";
      repo = "pinba_extension";
      rev = "RELEASE_1_1_1";
      sha256 = "1kdp7vav0y315695vhm3xifgsh6h6y6pny70xw3iai461n58khj5";
    };
  };

  zmq = buildPecl {
    pname = "zmq";
    version = "1.1.3";
    sha256 = "1kj487vllqj9720vlhfsmv32hs2dy2agp6176mav6ldx31c3g4n4";

    configureFlags = [ "--with-zmq=${pkgs.zeromq}" ];
    nativeBuildInputs = [ pkgs.pkgconfig ];
  };

}
