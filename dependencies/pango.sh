: ${PANGO_DEPENDENCIES:=cairo}
: ${PANGO_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${PANGO_TARBALL:="${DEPENDENCIES_DIR}/pango-1.36.1.tar.xz"}
: ${PANGO_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/pango-1.0/pango/pango.h"}

#-------------------------------------------------------------------------------
install_pango()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${PANGO_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${PANGO_INSTALLED_FILE}" ]; then
      mkdir -p "pango"  || fail "Unable to create application workspace"
      cd "pango/"       || fail "Unable to change into the application workspace"

      unxz "${PANGO_TARBALL}"                   || fail "Unable to unpack application tarball"
      tar xvf "${PANGO_TARBALL%.xz}"            || fail "Unable to unpack application tarball"
      cd "$(basename ${PANGO_TARBALL%.tar.xz})" || fail "Unable to change into application source directory"

      ./configure ${PANGO_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] pango is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
