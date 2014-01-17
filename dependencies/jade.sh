: ${JADE_DEPENDENCIES:=opensp}
: ${JADE_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${JADE_TARBALL:="${DEPENDENCIES_DIR}/jade-5.1.72.tar.gz"}
: ${JADE_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/jade/jade.h"}

#-------------------------------------------------------------------------------
install_jade()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${JADE_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${JADE_INSTALLED_FILE}" ]; then
      mkdir -p "jade"  || fail "Unable to create application workspace"
      cd "jade/"       || fail "Unable to change into the application workspace"

      tar xzvf "${JADE_TARBALL}"               || fail "Unable to unpack application tarball"
      cd "$(basename ${JADE_TARBALL%.tar.gz})" || fail "Unable to change into application source directory"

      ./configure ${JADE_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] jade is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
