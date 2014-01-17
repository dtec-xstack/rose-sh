: ${LIBRSVG_DEPENDENCIES:=glib gtk pango libxml2 cairo fontconfig freetype}
: ${LIBRSVG_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --enable-vala=no
    --enable-introspection=no
  }
: ${LIBRSVG_TARBALL:="${DEPENDENCIES_DIR}/librsvg-2.40.0.tar.xz"}
: ${LIBRSVG_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/rsvg.h"}

#-------------------------------------------------------------------------------
install_librsvg()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBRSVG_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBRSVG_INSTALLED_FILE}" ]; then
      mkdir -p "librsvg"  || fail "Unable to create application workspace"
      cd "librsvg/"       || fail "Unable to change into the application workspace"

      unxz "${LIBRSVG_TARBALL}"                   || fail "Unable to unpack application tarball"
      tar xvf "${LIBRSVG_TARBALL%.xz}"            || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBRSVG_TARBALL%.tar.xz})" || fail "Unable to change into application source directory"

      ./configure ${LIBRSVG_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] librsvg is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
