: ${GTK3_DEPENDENCIES:=glib atk pango cairo cairo_gobject gdk_pixbuf}
: ${GTK3_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${GTK3_TARBALL:="${DEPENDENCIES_DIR}/gtk+-3.8.5.tar.xz"}
: ${GTK3_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/gtk3-1.0/gtk3/gtk3.h"}

#-------------------------------------------------------------------------------
install_gtk3()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${GTK3_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${GTK3_INSTALLED_FILE}" ]; then
      mkdir -p "gtk3"  || fail "Unable to create application workspace"
      cd "gtk3/"       || fail "Unable to change into the application workspace"

      unxz "${GTK3_TARBALL}"                   || fail "Unable to unpack application tarball"
      tar xvf "${GTK3_TARBALL%.xz}"            || fail "Unable to unpack application tarball"
      cd "$(basename ${GTK3_TARBALL%.tar.xz})" || fail "Unable to change into application source directory"

      ./configure ${GTK3_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] gtk3 is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
