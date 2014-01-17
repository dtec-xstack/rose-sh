: ${LIBXCB_DEPENDENCIES:=libxslt xcb_proto}
: ${LIBXCB_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --disable-selinux
    --enable-xinput
    --enable-xkb
  }
: ${LIBXCB_TARBALL:="${DEPENDENCIES_DIR}/libxcb-1.9.1.tar.bz2"}
: ${LIBXCB_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/lib/libxcb.a"}

#-------------------------------------------------------------------------------
install_libxcb()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBXCB_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBXCB_INSTALLED_FILE}" ]; then
      mkdir -p "libxcb"  || fail "Unable to create application workspace"
      cd "libxcb/"       || fail "Unable to change into the application workspace"

      tar xjvf "${LIBXCB_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBXCB_TARBALL%.tar.bz2})" || fail "Unable to change into application source directory"

      ./configure ${LIBXCB_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] libxcb is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
