{ pkgs ? import <nixpkgs> { }, stdenv ? pkgs.stdenv, ... }:

with pkgs;
with pkgs.lib;
{ version, sha256
, url ? "https://www.php.net/distributions/php-${version}.tar.bz2"
, extraPatches ? [ ], isPhp74 ? versionAtLeast version "7.4"
, withSystemd ? stdenv.isLinux, imapSupport ? !stdenv.isDarwin
, ldapSupport ? true, mhashSupport ? true, mysqlndSupport ? true
, mysqliSupport ? true, pdo_mysqlSupport ? true, libxml2Support ? true
, apxs2Support ? !stdenv.isDarwin, embedSupport ? false, bcmathSupport ? true
, socketsSupport ? true, curlSupport ? true, gettextSupport ? true
, pcntlSupport ? true, pdo_odbcSupport ? true, postgresqlSupport ? true
, pdo_pgsqlSupport ? true, readlineSupport ? true, sqliteSupport ? true
, soapSupport ? libxml2Support, zlibSupport ? !isPhp74, opensslSupport ? true
, mbstringSupport ? true, gdSupport ? true, intlSupport ? true
, exifSupport ? true, xslSupport ? false
, mcryptSupport ? versionOlder version "7.2", bz2Support ? false
, zipSupport ? true, ftpSupport ? true, fpmSupport ? true, gmpSupport ? true
, ztsSupport ? apxs2Support, calendarSupport ? true
, sodiumSupport ? versionAtLeast version "7.2", tidySupport ? false
, argon2Support ? versionAtLeast version "7.2"
, libzipSupport ? versionAtLeast version "7.2", phpdbgSupport ? true
, cgiSupport ? true, cliSupport ? true, pharSupport ? true
, xmlrpcSupport ? libxml2Support, re2cSupport ? true, cgotoSupport ? false
, valgrindSupport ? versionAtLeast version "7.2"
, valgrindPcreSupport ? valgrindSupport && (versionAtLeast version "7.2") }:

let
  mysqlBuildInputs =
    optionals (!mysqlndSupport) [ mysql.connector-c mysql.dev ];
  libmcrypt' = libmcrypt.override { disablePosixThreads = true; };
in stdenv.mkDerivation {

  inherit version;

  name = "php-${version}";

  enableParallelBuilding = true;

  nativeBuildInputs = [ pkgconfig autoconf re2c ];
  buildInputs = [ flex bison ] ++ optional (versionOlder version "7.3") pcre
    ++ optional (versionAtLeast version "7.3") pcre2
    ++ optionals isPhp74 [ oniguruma libpng libjpeg zlib ]
    ++ optional withSystemd systemd
    ++ optionals imapSupport [ uwimap openssl pam ]
    ++ optionals curlSupport [ curl openssl ]
    ++ optionals (curlSupport && isPhp74) [ curl.dev openssl.dev ]
    ++ optionals ldapSupport [ openldap openssl ]
    ++ optionals gdSupport [ libpng libjpeg freetype ]
    ++ optionals opensslSupport [ openssl openssl.dev ]
    ++ optional apxs2Support apacheHttpd
    ++ optional (ldapSupport && stdenv.isLinux) cyrus_sasl
    ++ optional (ldapSupport && stdenv.isLinux && isPhp74) cyrus_sasl.dev
    ++ optional mhashSupport libmhash ++ optional zlibSupport zlib
    ++ optional libxml2Support libxml2
    ++ optional (libxml2Support && isPhp74) libxml2.dev
    ++ optional readlineSupport readline ++ optional sqliteSupport sqlite
    ++ optional (sqliteSupport && isPhp74) sqlite.dev
    ++ optional postgresqlSupport postgresql
    ++ optional pdo_odbcSupport unixODBC ++ optional pdo_pgsqlSupport postgresql
    ++ optional pdo_mysqlSupport mysqlBuildInputs
    ++ optional mysqliSupport mysqlBuildInputs ++ optional gmpSupport gmp
    ++ optional gettextSupport gettext ++ optional intlSupport icu
    ++ optional xslSupport libxslt
    ++ optional (xslSupport && isPhp74) libxslt.dev
    ++ optional mcryptSupport libmcrypt' ++ optional bz2Support bzip2
    ++ optional sodiumSupport libsodium
    ++ optional (sodiumSupport && isPhp74) libsodium.dev
    ++ optional tidySupport html-tidy ++ optional argon2Support libargon2
    ++ optional libzipSupport libzip
    ++ optional (libzipSupport && isPhp74) libzip.dev
    ++ optional (zipSupport && isPhp74) libzip.dev
    ++ optional valgrindSupport valgrind;

  CXXFLAGS = optional stdenv.cc.isClang "-std=c++11";

  configureFlags = [ "--with-config-file-scan-dir=/etc/php.d" ]
    ++ optional (versionOlder version "7.3")
    "--with-pcre-regex=${pcre.dev} PCRE_LIBDIR=${pcre}"
    ++ optional (!isPhp74 && versionAtLeast version "7.3")
    "--with-pcre-regex=${pcre2.dev} PCRE_LIBDIR=${pcre2}"
    ++ optional (isPhp74) "--with-external-pcre=${pcre.dev} PCRE_LIBDIR=${pcre}"
    ++ optional stdenv.isDarwin "--with-iconv=${libiconv}"
    ++ optional withSystemd "--with-fpm-systemd"
    ++ optionals imapSupport [ "--with-imap=${uwimap}" "--with-imap-ssl" ]
    ++ optionals ldapSupport [
      "--with-ldap=/invalid/path"
      "LDAP_DIR=${openldap.dev}"
      "LDAP_INCDIR=${openldap.dev}/include"
      "LDAP_LIBDIR=${openldap.out}/lib"
    ] ++ optional (ldapSupport && stdenv.isLinux && !isPhp74)
    "--with-ldap-sasl=${cyrus_sasl.dev}"
    ++ optional (ldapSupport && stdenv.isLinux && isPhp74) "--with-ldap-sasl"
    ++ optional apxs2Support "--with-apxs2=${apacheHttpd.dev}/bin/apxs"
    ++ optional embedSupport "--enable-embed"
    ++ optional mhashSupport "--with-mhash"
    ++ optional (curlSupport && !isPhp74) "--with-curl=${curl.dev}"
    ++ optional (curlSupport && isPhp74) "--with-curl"
    ++ optional zlibSupport "--with-zlib=${zlib.dev}"
    ++ optional (libxml2Support && !isPhp74) "--with-libxml-dir=${libxml2.dev}"
    ++ optional (libxml2Support && isPhp74) "--with-libxml"
    ++ optional (!libxml2Support) [
      "--disable-dom"
      "--disable-libxml"
      "--disable-simplexml"
      "--disable-xml"
      "--disable-xmlreader"
      "--disable-xmlwriter"
      "--without-pear"
    ] ++ optional pcntlSupport "--enable-pcntl"
    ++ optional readlineSupport "--with-readline=${readline.dev}"
    ++ optional (sqliteSupport && !isPhp74) "--with-pdo-sqlite=${sqlite.dev}"
    ++ optional (sqliteSupport && isPhp74) "--with-pdo-sqlite"
    ++ optional postgresqlSupport "--with-pgsql=${postgresql}"
    ++ optional pdo_odbcSupport "--with-pdo-odbc=unixODBC,${unixODBC}"
    ++ optional pdo_pgsqlSupport "--with-pdo-pgsql=${postgresql}"
    ++ optional pdo_mysqlSupport "--with-pdo-mysql=${
      if mysqlndSupport then "mysqlnd" else mysql.connector-c
    }" ++ optionals mysqliSupport [
      "--with-mysqli=${
        if mysqlndSupport then
          "mysqlnd"
        else
          "${mysql.connector-c}/bin/mysql_config"
      }"
    ] ++ optional (pdo_mysqlSupport || mysqliSupport)
    "--with-mysql-sock=/run/mysqld/mysqld.sock" ++ optional bcmathSupport
    "--enable-bcmath"
    # FIXME: Our own gd package doesn't work, see https://bugs.php.net/bug.php?id=60108.
    ++ optionals (gdSupport && !isPhp74) [
      "--with-gd"
      "--with-png-dir=${libpng.dev}"
      "--with-jpeg-dir=${libjpeg.dev}"
      "--with-freetype-dir=${freetype.dev}"
    ] ++ optionals (gdSupport && isPhp74) [
      "--enable-gd"
      "--with-freetype"
      "--with-jpeg"
    ] ++ optional gmpSupport "--with-gmp=${gmp.dev}"
    ++ optional soapSupport "--enable-soap"
    ++ optional socketsSupport "--enable-sockets"
    ++ optional opensslSupport "--with-openssl"
    ++ optional mbstringSupport "--enable-mbstring"
    ++ optional gettextSupport "--with-gettext=${gettext}"
    ++ optional intlSupport "--enable-intl"
    ++ optional exifSupport "--enable-exif"
    ++ optional (xslSupport && !isPhp74) "--with-xsl=${libxslt.dev}"
    ++ optional (xslSupport && isPhp74) "--with-xsl"
    ++ optional mcryptSupport "--with-mcrypt=${libmcrypt'}"
    ++ optional bz2Support "--with-bz2=${bzip2.dev}"
    ++ optional (zipSupport && !isPhp74) "--enable-zip"
    ++ optional (zipSupport && isPhp74) "--with-zip"
    ++ optional ftpSupport "--enable-ftp" ++ optional fpmSupport "--enable-fpm"
    ++ optional ztsSupport "--enable-maintainer-zts"
    ++ optional calendarSupport "--enable-calendar"
    ++ optional (sodiumSupport && !isPhp74) "--with-sodium=${libsodium.dev}"
    ++ optional (sodiumSupport && isPhp74) "--with-sodium"
    ++ optional tidySupport "--with-tidy=${html-tidy}"
    ++ optional argon2Support "--with-password-argon2=${libargon2}"
    ++ optional (libzipSupport && !isPhp74) "--with-libzip=${libzip.dev}"
    ++ optional phpdbgSupport "--enable-phpdbg"
    ++ optional (!phpdbgSupport) "--disable-phpdbg"
    ++ optional (!cgiSupport) "--disable-cgi"
    ++ optional (!cliSupport) "--disable-cli"
    ++ optional (!pharSupport) "--disable-phar"
    ++ optional xmlrpcSupport "--with-xmlrpc"
    ++ optional cgotoSupport "--enable-re2c-cgoto"
    ++ optional valgrindSupport "--with-valgrind=${valgrind.dev}"
    ++ optional valgrindPcreSupport "--with-pcre-valgrind";

  hardeningDisable = [ "bindnow" ];

  preConfigure = ''
    # Don't record the configure flags since this causes unnecessary
    # runtime dependencies
    for i in main/build-defs.h.in scripts/php-config.in; do
      substituteInPlace $i \
        --replace '@CONFIGURE_COMMAND@' '(omitted)' \
        --replace '@CONFIGURE_OPTIONS@' "" \
        --replace '@PHP_LDFLAGS@' ""
    done
    #[[ -z "$libxml2" ]] || addToSearchPath PATH $libxml2/bin
    export EXTENSION_DIR=$out/lib/php/extensions
    configureFlags+=(--with-config-file-path=$out/etc \
      --includedir=$dev/include)
    ./buildconf --force
  '';

  postInstall = ''
    test -d $out/etc || mkdir $out/etc
    cp php.ini-production $out/etc/php.ini
  '';

  postFixup = ''
    mkdir -p $dev/bin $dev/share/man/man1
    mv $out/bin/phpize $out/bin/php-config $dev/bin/
    mv $out/share/man/man1/phpize.1.gz \
      $out/share/man/man1/php-config.1.gz \
      $dev/share/man/man1/
  '';

  src = fetchurl { inherit url sha256; };

  meta = with stdenv.lib; {
    description = "An HTML-embedded scripting language";
    homepage = "https://www.php.net/";
    license = licenses.php301;
    maintainers = with maintainers; [ globin etu ];
    platforms = platforms.all;
    outputsToInstall = [ "out" "dev" ];
  };

  patches = [ ./fix-paths.patch ] ++ extraPatches;

  postPatch = optional stdenv.isDarwin ''
    substituteInPlace configure --replace "-lstdc++" "-lc++"
  '';

  stripDebugList = "bin sbin lib modules";

  outputs = [ "out" "dev" ];
}

