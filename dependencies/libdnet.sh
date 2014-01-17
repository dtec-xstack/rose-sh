: ${LIBDNET_DEPENDENCIES:=libpcap}
: ${LIBDNET_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --without-python
  }
: ${LIBDNET_TARBALL:="${DEPENDENCIES_DIR}/libdnet-1.12.tgz"}
: ${LIBDNET_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/dnet.h"}

#-------------------------------------------------------------------------------
install_libdnet()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBDNET_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBDNET_INSTALLED_FILE}" ]; then
      mkdir -p "libdnet"  || fail "Unable to create application workspace"
      cd "libdnet/"       || fail "Unable to change into the application workspace"

      tar xzvf "${LIBDNET_TARBALL}"               || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBDNET_TARBALL%.tgz})" || fail "Unable to change into application source directory"

      ./configure ${LIBDNET_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] libdnet is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
