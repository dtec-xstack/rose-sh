: ${LIBSSH2_DEPENDENCIES:=zlib libgcrypt libgpg_error openssl}

#-------------------------------------------------------------------------------
install_libssh2()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBSSH2_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${ROSE_SH_DEPS_PREFIX}/include/libssh2.h" ]; then
      mkdir -p "libssh2"  || exit 1
      cd "libssh2/"    || exit 1

      tar xzvf "${DEPENDENCIES_DIR}/libssh2-1.4.3.tar.gz" || exit 1
      cd "libssh2-1.4.3/" || exit 1

      ./configure \
          --prefix="$ROSE_SH_DEPS_PREFIX" \
          --libdir="$ROSE_SH_DEPS_LIBDIR" \
          \
              --with-libgcrypt \
              --with-libgcrypt-prefix="${ROSE_SH_DEPS_PREFIX}" \
              --with-libz \
              --with-libz-prefix="${ROSE_SH_DEPS_PREFIX}" \
              --with-libssl-prefix="${ROSE_SH_DEPS_PREFIX}" \
          \
          || exit 1

      make -j${parallelism} || exit 1
      make -j${parallelism} install || exit 1
  else
      info "[SKIP] libssh2 is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
