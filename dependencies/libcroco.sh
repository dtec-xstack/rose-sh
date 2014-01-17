: ${LIBCROCO_DEPENDENCIES:=glib libxml2}
: ${LIBCROCO_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"}
: ${LIBCROCO_TARBALL:="${DEPENDENCIES_DIR}/libcroco-0.6.8.tar.xz"}
: ${LIBCROCO_SOURCE_DIRNAME:="libcroco-0.6.8"}
: ${LIBCROCO_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/libcroco-0.6/libcroco/libcroco.h"}

#-------------------------------------------------------------------------------
install_libcroco()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBCROCO_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBCROCO_INSTALLED_FILE}" ]; then
      mkdir -p "libcroco"  || fail "Unable to create application workspace"
      cd "libcroco/"       || fail "Unable to change into the application workspace"

      unxz "${LIBCROCO_TARBALL}"        || fail "Unable to unpack application tarball"
      tar xvf "${LIBCROCO_TARBALL%.xz}" || fail "Unable to unpack application tarball"
      cd "${LIBCROCO_SOURCE_DIRNAME}"   || fail "Unable to change into application source directory"

      ./configure ${LIBCROCO_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] libcroco is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
