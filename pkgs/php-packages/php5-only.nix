{ pkgs, buildPecl, php' }:

rec {
  apcu = buildPecl {
    pname = "apcu";
    version = "4.0.11";
    sha256 = "002d1gklkf0z170wkbhmm2z1p9p5ghhq3q1r9k54fq1sq4p30ks5";

    buildInputs = [ pkgs.pcre ];
    makeFlags = [ "phpincludedir=$(dev)/include" ];
    outputs = [ "out" "dev" ];
  };

  memcache = buildPecl {
    pname = "memcache";
    version = "3.0.8";
    sha256 = "04c35rj0cvq5ygn2jgmyvqcb0k8d03v4k642b6i37zgv7x15pbic";

    configureFlags = [ "--with-zlib-dir=${pkgs.zlib.dev}" ];
    makeFlags = [ "CFLAGS=-fgnu89-inline" ];
  };

  memcached = buildPecl {
    pname = "memcached";
    version = "2.2.0";
    sha256 = "0n4z2mp4rvrbmxq079zdsrhjxjkmhz6mzi7mlcipz02cdl7n1f8p";

    configureFlags = [
      "--with-zlib-dir=${pkgs.zlib.dev}"
      "--with-libmemcached-dir=${pkgs.libmemcached}"
    ];
    nativeBuildInputs = [ pkgs.pkgconfig ];
    buildInputs = with pkgs; [ cyrus_sasl zlib ];
  };

  spidermonkey = buildPecl rec {
    pname = "spidermonkey";
    version = "1.0.0";
    sha256 = "1ywrsp90w6rlgq3v2vmvp2zvvykkgqqasab7h9bf3vgvgv3qasbg";

    configureFlags = [ "--with-spidermonkey=${pkgs.spidermonkey_1_8_5}" ];
    buildInputs = [ pkgs.spidermonkey_1_8_5 ];
  };

  xdebug = buildPecl {
    pname = "xdebug";
    version = "2.3.1";
    sha256 = "0k567i6w7cw14m13s7ip0946pvy5ii16cjwjcinnviw9c24na0xm";

    doCheck = true;
    checkTarget = "test";
  };

  yaml = buildPecl {
    pname = "yaml";
    version = "1.3.1";
    sha256 = "1fbmgsgnd6l0d4vbjaca0x9mrfgl99yix5yf0q0pfcqzfdg4bj8q";

    configureFlags = [ "--with-yaml=${pkgs.libyaml}" ];
    nativeBuildInputs = [ pkgs.pkgconfig ];
  };

  xcache = buildPecl rec {
    pname = "xcache";
    version = "3.2.0";

    src = pkgs.fetchurl {
      url =
        "http://xcache.lighttpd.net/pub/Releases/${version}/${pname}.tar.bz2";
      sha256 = "1gbcpw64da9ynjxv70jybwf9y88idm01kb16j87vfagpsp5s64kx";
    };

    doCheck = true;
    checkTarget = "test";

    configureFlags = [
      "--enable-xcache"
      "--enable-xcache-coverager"
      "--enable-xcache-optimizer"
      "--enable-xcache-assembler"
      "--enable-xcache-encoder"
      "--enable-xcache-decoder"
    ];

    buildInputs = [ pkgs.m4 ];
  };

  geoip = buildPecl {
    pname = "geoip";
    version = "1.1.0";
    sha256 = "1fcqpsvwba84gqqmwyb5x5xhkazprwkpsnn4sv2gfbsd4svxxil2";

    configureFlags = [ "--with-geoip=${pkgs.geoip}" ];

    buildInputs = [ pkgs.geoip ];
  };

  redis = buildPecl {
    pname = "redis";
    version = "2.2.7";
    sha256 = "00n9dpk9ak0bl35sbcd3msr78sijrxdlb727nhg7f2g7swf37rcm";
  };
}
