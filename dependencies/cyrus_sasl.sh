: ${CYRUS_SASL_DEPENDENCIES:=gdbm db openssl zlib}

#-------------------------------------------------------------------------------
install_cyrus_sasl()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${CYRUS_SASL_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${ROSE_SH_DEPS_PREFIX}/include/sasl/sasl.h" ]; then
      mkdir -p "cyrus_sasl"  || exit 1
      cd "cyrus_sasl/"    || exit 1

      tar xzvf "${DEPENDENCIES_DIR}/cyrus-sasl-2.1.26.tar.gz" || exit 1
      cd "cyrus-sasl-2.1.26/" || exit 1

      ./configure \
          --prefix="$ROSE_SH_DEPS_PREFIX" \
          --libdir="$ROSE_SH_DEPS_LIBDIR" \
          \
              --enable-static \
              --with-devrandom=/dev/urandom \
              --disable-ntlm \
              --disable-krb4 \
              --disable-ldapdb \
              --disable-macos-framework \
              --with-javabase="${ROSE_SH_DEPS_PREFIX}/java/include" \
              --with-dbpath="${ROSE_SH_DEPS_PREFIX}/etc/sasldb2" \
              --with-dblib=berkeley \
              --with-bdb-libdir="${ROSE_SH_DEPS_PREFIX}/lib" \
              --with-bdb-incdir="${ROSE_SH_DEPS_PREFIX}/include" \
              --with-gdbm="${ROSE_SH_DEPS_PREFIX}" \
              --with-openssl="${ROSE_SH_DEPS_PREFIX}" \
              --with-sqlite3="${ROSE_SH_DEPS_PREFIX}" \
              --with-plugindir="${ROSE_SH_DEPS_PREFIX}/lib/sasl2" \
              --with-configdir="${ROSE_SH_DEPS_PREFIX}/lib/sasl2" \
              --disable-gssapi \
          \
          || exit 1

      make -j${parallelism} || exit 1
      make -j${parallelism} install || exit 1
  else
      info "[SKIP] cyrus_sasl is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
