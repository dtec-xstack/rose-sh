: ${LIBGSF_DEPENDENCIES:=glib bzip2 zlib libxml2 gdk_pixbuf}
: ${LIBGSF_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --with-zlib="${ROSE_SH_DEPS_PREFIX}"
    --with-bz2
    --with-gdk-pixbuf
  }
: ${LIBGSF_TARBALL:="libgsf-1.14.28.tar.xz"}
: ${LIBGSF_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/libgsf-1/gsf/gsf.h"}

#-------------------------------------------------------------------------------
install_libgsf()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBGSF_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBGSF_INSTALLED_FILE}" ]; then
      rm -rf "./libgsf"  || fail "Unable to remove old application workspace"
      mkdir -p "libgsf"  || fail "Unable to create application workspace"
      cd "libgsf/"       || fail "Unable to change into the application workspace"

      download_tarball "${LIBGSF_TARBALL}"        || fail "Unable to download application tarball"
      unxz "${LIBGSF_TARBALL}"                    || fail "Unable to unpack application tarball"
      tar xvf "${LIBGSF_TARBALL%.xz}"             || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBGSF_TARBALL%.tar.xz})"  || fail "Unable to change into application source directory"

      ./configure ${LIBGSF_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] libgsf is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
