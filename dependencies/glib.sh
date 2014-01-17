# NOTE: Requires Python.  Should we include a controlled version of python?
#       Use --with-python=/opt/stonesoup/... if desired.

: ${GLIB_DEPENDENCIES:=libffi pcre zlib}
: ${GLIB_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --exec-prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --enable-static
    --with-pcre=system
  }
: ${GLIB_TARBALL:="${DEPENDENCIES_DIR}/glib-2.38.0.tar.xz"}
: ${GLIB_SOURCE_DIRNAME:="glib-2.38.0"}
: ${GLIB_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/glib-2.0/glib.h"}

#-------------------------------------------------------------------------------
install_glib()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${GLIB_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${GLIB_INSTALLED_FILE}" ]; then
      mkdir -p "glib"  || fail "Unable to create application workspace"
      cd "glib/"       || fail "Unable to change into the application workspace"

      unxz "${GLIB_TARBALL}"        || fail "Unable to unpack application tarball"
      tar xvf "${GLIB_TARBALL%.xz}" || fail "Unable to unpack application tarball"
      cd "${GLIB_SOURCE_DIRNAME}"   || fail "Unable to change into application source directory"

      ./configure ${GLIB_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] glib is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
