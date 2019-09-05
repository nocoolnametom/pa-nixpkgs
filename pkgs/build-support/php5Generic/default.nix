{ pkgs ? import <nixpkgs> { }, stdenv ? pkgs.stdenv, ... }:

with pkgs;
with pkgs.lib;
{ version, sha256, imapSupport ? !stdenv.isDarwin, ldapSupport ? true
, mhashSupport ? true, mysqlSupport ? true, mysqlndSupport ? true
, mysqliSupport ? true, pdo_mysqlSupport ? true, libxml2Support ? true
, apxs2Support ? !stdenv.isDarwin, embedSupport ? false, bcmathSupport ? true
, socketsSupport ? true, curlSupport ? true, curlWrappersSupport ? true
, gettextSupport ? true, pcntlSupport ? true, postgresqlSupport ? true
, pdo_pgsqlSupport ? true, readlineSupport ? true, sqliteSupport ? true
, soapSupport ? true, zlibSupport ? true, opensslSupport ? true
, mbstringSupport ? true, gdSupport ? true, intlSupport ? true
, exifSupport ? true, xslSupport ? false, mcryptSupport ? true
, bz2Support ? false, zipSupport ? true, ftpSupport ? true, fpmSupport ? true
, gmpSupport ? true, mssqlSupport ? !stdenv.isDarwin, ztsSupport ? false
, calendarSupport ? true, tidySupport ? false }:
let
  mysqlBuildInputs = optional (!mysqlndSupport) mysql.connector-c;
  libmcrypt' = libmcrypt.override { disablePosixThreads = true; };
in stdenv.mkDerivation {
  inherit version;
  name = "php-${version}";
  enableParallelBuilding = true;
  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ flex bison pcre ] ++ optional stdenv.isLinux systemd
    ++ optionals imapSupport [ uwimap openssl pam ]
    ++ optionals curlSupport [ curl openssl ]
    ++ optionals ldapSupport [ openldap openssl ]
    ++ optionals gdSupport [ libpng libjpeg freetype ]
    ++ optionals opensslSupport [ openssl openssl.dev ]
    ++ optional apxs2Support apacheHttpd
    ++ optional (ldapSupport && stdenv.isLinux) cyrus_sasl
    ++ optional mhashSupport libmhash ++ optional zlibSupport zlib
    ++ optional libxml2Support libxml2 ++ optional readlineSupport readline
    ++ optional sqliteSupport sqlite ++ optional postgresqlSupport postgresql
    ++ optional pdo_pgsqlSupport postgresql
    ++ optional pdo_mysqlSupport mysqlBuildInputs
    ++ optional mysqlSupport mysqlBuildInputs
    ++ optional mysqliSupport mysqlBuildInputs ++ optional gmpSupport gmp
    ++ optional gettextSupport gettext ++ optional intlSupport icu
    ++ optional xslSupport libxslt ++ optional mcryptSupport libmcrypt'
    ++ optional bz2Support bzip2
    ++ optional (mssqlSupport && !stdenv.isDarwin) freetds
    ++ optional tidySupport html-tidy;
  CXXFLAGS = optional stdenv.cc.isClang "-std=c++11";
  configureFlags = [
    "--with-config-file-scan-dir=/etc/php.d"
    "--with-pcre-regex=${pcre.dev} PCRE_LIBDIR=${pcre}"
  ] ++ optional stdenv.isDarwin "--with-iconv=${libiconv}"
    ++ optional stdenv.isLinux "--with-fpm-systemd"
    ++ optionals imapSupport [ "--with-imap=${uwimap}" "--with-imap-ssl" ]
    ++ optionals ldapSupport [
      "--with-ldap=/invalid/path"
      "LDAP_DIR=${openldap.dev}"
      "LDAP_INCDIR=${openldap.dev}/include"
      "LDAP_LIBDIR=${openldap.out}/lib"
    ] ++ optional (ldapSupport && stdenv.isLinux)
    "--with-ldap-sasl=${cyrus_sasl.dev}"
    ++ optional apxs2Support "--with-apxs2=${apacheHttpd.dev}/bin/apxs"
    ++ optional embedSupport "--enable-embed"
    ++ optional mhashSupport "--with-mhash"
    ++ optional curlSupport "--with-curl=${curl.dev}"
    ++ optional curlWrappersSupport "--with-curlwrappers"
    ++ optional zlibSupport "--with-zlib=${zlib.dev}"
    ++ optional libxml2Support "--with-libxml-dir=${libxml2.dev}"
    ++ optional pcntlSupport "--enable-pcntl"
    ++ optional readlineSupport "--with-readline=${readline.dev}"
    ++ optional sqliteSupport "--with-pdo-sqlite=${sqlite.dev}"
    ++ optional postgresqlSupport "--with-pgsql=${postgresql}"
    ++ optional pdo_pgsqlSupport "--with-pdo-pgsql=${postgresql}"
    ++ optional pdo_mysqlSupport "--with-pdo-mysql=${
      if mysqlndSupport then "mysqlnd" else mysql.connector-c
    }" ++ optional mysqlSupport
    "--with-mysql${if mysqlndSupport then "=mysqlnd" else ""}"
    ++ optionals mysqliSupport [
      "--with-mysqli=${
        if mysqlndSupport then
          "mysqlnd"
        else
          "${mysql.connector-c}/bin/mysql_config"
      }"
    ] ++ optional bcmathSupport "--enable-bcmath"
    # FIXME: Our own gd package doesn't work, see https://bugs.php.net/bug.php?id=60108.
    ++ optionals gdSupport [
      "--with-gd"
      "--with-freetype-dir=${freetype.dev}"
      "--with-png-dir=${libpng.dev}"
      "--with-jpeg-dir=${libjpeg.dev}"
    ] ++ optional gmpSupport "--with-gmp=${gmp.dev}"
    ++ optional soapSupport "--enable-soap"
    ++ optional socketsSupport "--enable-sockets"
    ++ optional opensslSupport "--with-openssl"
    ++ optional mbstringSupport "--enable-mbstring"
    ++ optional gettextSupport "--with-gettext=${gettext}"
    ++ optional intlSupport "--enable-intl"
    ++ optional exifSupport "--enable-exif"
    ++ optional xslSupport "--with-xsl=${libxslt.dev}"
    ++ optional mcryptSupport "--with-mcrypt=${libmcrypt'}"
    ++ optional bz2Support "--with-bz2=${bzip2.dev}"
    ++ optional zipSupport "--enable-zip" ++ optional ftpSupport "--enable-ftp"
    ++ optional fpmSupport "--enable-fpm"
    ++ optional (mssqlSupport && !stdenv.isDarwin) "--with-mssql=${freetds}"
    ++ optional ztsSupport "--enable-maintainer-zts"
    ++ optional calendarSupport "--enable-calendar"
    ++ optional tidySupport "--with-tidy=${html-tidy}";
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
  '';
  postInstall = ''
    cp php.ini-production $out/etc/php.ini
  '';
  postFixup = ''
    mkdir -p $dev/bin $dev/share/man/man1
    mv $out/bin/phpize $out/bin/php-config $dev/bin/
    mv $out/share/man/man1/phpize.1.gz \
      $out/share/man/man1/php-config.1.gz \
      $dev/share/man/man1/
  '';
  src = fetchurl {
    url = "http://www.php.net/distributions/php-${version}.tar.bz2";
    inherit sha256;
  };
  meta = with stdenv.lib; {
    description = "An HTML-embedded scripting language";
    homepage = "http://www.php.net/";
    license = licenses.php301;
    maintainers = with maintainers; [ globin etu ];
    platforms = platforms.all;
    outputsToInstall = [ "out" "dev" ];
  };
  # Whitespace on non-empty lines matters in the patch file below; make sure an IDE doesn't "correct" your spacing!
  patches = [
    (pkgs.writeText "fix-paths.patch" ''
      diff -ru php-5.4.14/configure php-5.4.14-new/configure
      --- php-5.4.14/configure        2013-04-10 09:53:26.000000000 +0200
      +++ php-5.4.14-new/configure    2013-04-22 17:13:55.039043622 +0200
      @@ -6513,7 +6513,7 @@

         case $host_alias in
         *aix*)
      -    APXS_LIBEXECDIR=`$APXS -q LIBEXECDIR`
      +    APXS_LIBEXECDIR="$prefix/modules"
           EXTRA_LDFLAGS="$EXTRA_LDFLAGS -Wl,-brtl -Wl,-bI:$APXS_LIBEXECDIR/httpd.exp"
           PHP_AIX_LDFLAGS="-Wl,-brtl"
           build_type=shared
      @@ -6706,7 +6706,7 @@
         if test "$?" != "0"; then
           APACHE_INSTALL="$APXS -i -a -n php5 $SAPI_SHARED" # Old apxs does not have -S option
         else
      -    APXS_LIBEXECDIR='$(INSTALL_ROOT)'`$APXS -q LIBEXECDIR`
      +    APXS_LIBEXECDIR="$prefix/modules"
           if test -z `$APXS -q SYSCONFDIR`; then
             APACHE_INSTALL="\$(mkinstalldirs) '$APXS_LIBEXECDIR' && \
                               $APXS -S LIBEXECDIR='$APXS_LIBEXECDIR' \
      @@ -7909,7 +7909,7 @@
           { (exit 1); exit 1; }; }
         fi

      -  APXS_LIBEXECDIR='$(INSTALL_ROOT)'`$APXS -q LIBEXECDIR`
      +  APXS_LIBEXECDIR="$prefix/modules"
         if test -z `$APXS -q SYSCONFDIR`; then
           INSTALL_IT="\$(mkinstalldirs) '$APXS_LIBEXECDIR' && \
                         $APXS -S LIBEXECDIR='$APXS_LIBEXECDIR' \
      @@ -8779,7 +8779,7 @@
           { (exit 1); exit 1; }; }
         fi

      -  APXS_LIBEXECDIR='$(INSTALL_ROOT)'`$APXS -q LIBEXECDIR`
      +  APXS_LIBEXECDIR="$prefix/modules"
         if test -z `$APXS -q SYSCONFDIR`; then
           INSTALL_IT="\$(mkinstalldirs) '$APXS_LIBEXECDIR' && \
                         $APXS -S LIBEXECDIR='$APXS_LIBEXECDIR' \
      @@ -9634,7 +9634,7 @@

         case $host_alias in
         *aix*)
      -    APXS_LIBEXECDIR=`$APXS -q LIBEXECDIR`
      +    APXS_LIBEXECDIR="$prefix/modules"
           EXTRA_LDFLAGS="$EXTRA_LDFLAGS -Wl,-brtl -Wl,-bI:$APXS_LIBEXECDIR/httpd.exp"
           PHP_AIX_LDFLAGS="-Wl,-brtl"
           build_type=shared
      @@ -9827,7 +9827,7 @@
         if test "$?" != "0"; then
           APACHE_HOOKS_INSTALL="$APXS -i -a -n php5 $SAPI_SHARED" # Old apxs does not have -S option
         else
      -    APXS_LIBEXECDIR='$(INSTALL_ROOT)'`$APXS -q LIBEXECDIR`
      +    APXS_LIBEXECDIR="$prefix/modules"
           if test -z `$APXS -q SYSCONFDIR`; then
             APACHE_HOOKS_INSTALL="\$(mkinstalldirs) '$APXS_LIBEXECDIR' && \
                               $APXS -S LIBEXECDIR='$APXS_LIBEXECDIR' \
      @@ -59657,9 +59657,7 @@


       if test "$PHP_GETTEXT" != "no"; then
      -  for i in $PHP_GETTEXT /usr/local /usr; do
      -    test -r $i/include/libintl.h && GETTEXT_DIR=$i && break
      -  done
      +  GETTEXT_DIR=$PHP_GETTEXT

         if test -z "$GETTEXT_DIR"; then
           { { $as_echo "$as_me:$LINENO: error: Cannot locate header file libintl.h" >&5
    '')
  ];
  postPatch = optional stdenv.isDarwin ''
    substituteInPlace configure --replace "-lstdc++" "-lc++"
  '';
  stripDebugList = "bin sbin lib modules";
  outputs = [ "out" "dev" ];
}

