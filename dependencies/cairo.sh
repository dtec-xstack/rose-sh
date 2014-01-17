: ${CAIRO_DEPENDENCIES:=libxcb fontconfig freetype zlib libpixman libpng}
: ${CAIRO_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${CAIRO_TARBALL:="${DEPENDENCIES_DIR}/cairo-1.12.16.tar.xz"}
: ${CAIRO_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/cairo-1.0/cairo/cairo.h"}

#-------------------------------------------------------------------------------
install_cairo()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${CAIRO_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${CAIRO_INSTALLED_FILE}" ]; then
      mkdir -p "cairo"  || fail "Unable to create application workspace"
      cd "cairo/"       || fail "Unable to change into the application workspace"

      unxz "${CAIRO_TARBALL}"                   || fail "Unable to unpack application tarball"
      tar xvf "${CAIRO_TARBALL%.xz}"            || fail "Unable to unpack application tarball"
      cd "$(basename ${CAIRO_TARBALL%.tar.xz})" || fail "Unable to change into application source directory"

      ./configure ${CAIRO_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] cairo is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
