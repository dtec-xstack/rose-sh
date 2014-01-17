: ${BABL_DEPENDENCIES:=}
: ${BABL_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${BABL_TARBALL:="${DEPENDENCIES_DIR}/babl-0.1.10.tar.bz2"}
: ${BABL_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/babl-0.1/babl/babl.h"}

#-------------------------------------------------------------------------------
install_babl()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${BABL_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${BABL_INSTALLED_FILE}" ]; then
      mkdir -p "babl"  || fail "Unable to create application workspace"
      cd "babl/"       || fail "Unable to change into the application workspace"

      tar xjvf "${BABL_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${BABL_TARBALL%.tar.bz2})" || fail "Unable to change into application source directory"

      ./configure ${BABL_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] babl is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
