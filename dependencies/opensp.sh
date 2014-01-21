: ${OPENSP_DEPENDENCIES:=sgml_common xmlto}
: ${OPENSP_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${OPENSP_TARBALL:="opensp-5.1.72.tar.gz"}
: ${OPENSP_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/opensp/opensp.h"}

#-------------------------------------------------------------------------------
install_opensp()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${OPENSP_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${OPENSP_INSTALLED_FILE}" ]; then
      rm -rf "./opensp"  || fail "Unable to remove old application workspace"
      mkdir -p "opensp"  || fail "Unable to create application workspace"
      cd "opensp/"       || fail "Unable to change into the application workspace"

      download_tarball "${OPENSP_TARBALL}"       || fail "Unable to download application tarball"
      tar xzvf "${OPENSP_TARBALL}"               || fail "Unable to unpack application tarball"
      cd "$(basename ${OPENSP_TARBALL%.tar.gz})" || fail "Unable to change into application source directory"

      ./configure ${OPENSP_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] opensp is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
