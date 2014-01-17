: ${LIBMICROHTTPD_DEPENDENCIES:=curl openssl}
: ${LIBMICROHTTPD_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --with-libcurl="${ROSE_SH_DEPS_PREFIX}"
    --with-openssl="${ROSE_SH_DEPS_PREFIX}"
    --with-libgcrypt-prefix="${ROSE_SH_DEPS_PREFIX}"}

#-------------------------------------------------------------------------------
install_libmicrohttpd()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBMICROHTTPD_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${ROSE_SH_DEPS_PREFIX}/include/microhttpd.h" ]; then
      mkdir -p "libmicrohttpd"  || exit 1
      cd "libmicrohttpd/"       || exit 1

      tar xzvf "${DEPENDENCIES_DIR}/libmicrohttpd-0.9.30.tar.gz" || fail "Unable to unpack tarball"
      cd "libmicrohttpd-0.9.30/" || exit 1

      ./configure ${LIBMICROHTTPD_CONFIGURE_OPTIONS} || fail "Unable to configure"

      make -j${parallelism}         || fail "An error occurred during compilation"
      make -j${parallelism} install || fail "An error occurred during installation"
  else
      info "[SKIP] libmicrohttpd is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
