: ${GEGL_DEPENDENCIES:=}
: ${GEGL_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${GEGL_TARBALL:="${DEPENDENCIES_DIR}/gegl-0.2.0.tar.bz2"}
: ${GEGL_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/gegl-0.2/gegl.h"}

#-------------------------------------------------------------------------------
install_gegl()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${GEGL_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${GEGL_INSTALLED_FILE}" ]; then
      mkdir -p "gegl"  || fail "Unable to create application workspace"
      cd "gegl/"       || fail "Unable to change into the application workspace"

      tar xjvf "${GEGL_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${GEGL_TARBALL%.tar.bz2})" || fail "Unable to change into application source directory"

      ./configure ${GEGL_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] gegl is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
