: ${DOVECOT_DEPENDENCIES:=zlib openldap}

#-------------------------------------------------------------------------------
download_dovecot()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      git clone \
          "rose-dev@rosecompiler1.llnl.gov:rose/c/${application}.git" \
          "${application}-src" \
          || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_dovecot()
#-------------------------------------------------------------------------------
{
  install_deps ${DOVECOT_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_dovecot()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_dovecot__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS" \
      LDFLAGS="$LDFLAGS" \
          CC="${ROSE_CC}" \
              ./configure \
                  --prefix="$(pwd)/install_tree" \
                  \
                      --with-notify=none \
                      --without-nss \
                      --with-shadow \
                      --without-pam \
                      --without-bsdauth \
                      --without-gssapi \
                      --with-ldap=yes \
                      --with-sqlite \
                      --without-pgsql \
                      --without-mysql \
                      --without-lucene \
                      --without-stemmer \
                      --without-solr \
                      --with-zlib \
                      --with-bzlib \
                      --without-libcap \
                      --with-ssl=openssl \
                      --without-libwrap \
                      --with-ssldir="$(pwd)/install/ssl" \
                  \
                  || exit 1
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_dovecot__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS" \
      LDFLAGS="$LDFLAGS" \
          CC="${CC}" \
              ./configure \
                  --prefix="$(pwd)/install_tree" \
                  \
                      --with-notify=none \
                      --without-nss \
                      --with-shadow \
                      --without-pam \
                      --without-bsdauth \
                      --without-gssapi \
                      --with-ldap=yes \
                      --with-sqlite \
                      --without-pgsql \
                      --without-mysql \
                      --without-lucene \
                      --without-stemmer \
                      --without-solr \
                      --with-zlib \
                      --with-bzlib \
                      --without-libcap \
                      --with-ssl=openssl \
                      --without-libwrap \
                      --with-ssldir="$(pwd)/install/ssl" \
                  \
                  || exit 1
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_dovecot()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  set -x
      make -j${parallelism}         || exit 1
      make -j${parallelism} install || exit 1
  set +x
}
