: ${GMP_DEPENDENCIES:=}
: ${GMP_CONFIGURE_OPTIONS:=
    ABI=64
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --exec-prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${GMP_TARBALL:="${DEPENDENCIES_DIR}/gmp-5.1.2.tar.bz2"}
: ${GMP_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/gmp.h"}

#-------------------------------------------------------------------------------
install_gmp()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${GMP_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${GMP_INSTALLED_FILE}" ]; then
      mkdir -p "gmp"  || fail "Unable to create application workspace"
      cd "gmp/"       || fail "Unable to change into the application workspace"

      tar xjvf "${GMP_TARBALL}"                 || fail "Unable to unpack application tarball"
      cd "$(basename ${GMP_TARBALL%.tar.bz2})"  || fail "Unable to change into application source directory"

      ./configure ${GMP_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] gmp is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
