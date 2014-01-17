: ${GETTEXT_DEPENDENCIES:=libcroco expat ncurses libxml2 libunistring}
: ${GETTEXT_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --exec-prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --with-libexpat-prefix="${ROSE_SH_DEPS_PREFIX}"
    --with-libncurses-prefix="${ROSE_SH_DEPS_PREFIX}"
    --with-libxml2-prefix="${ROSE_SH_DEPS_PREFIX}"
    --with-libunistring-prefix="${ROSE_SH_DEPS_PREFIX}"
    --with-included-libcroco
    --with-included-glib}
: ${GETTEXT_TARBALL:="${DEPENDENCIES_DIR}/gettext-0.18.3.1.tar.gz"}
: ${GETTEXT_SOURCE_DIRNAME:="gettext-0.18.3.1"}
: ${GETTEXT_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/gettext-po.h"}

#-------------------------------------------------------------------------------
install_gettext()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${GETTEXT_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${GETTEXT_INSTALLED_FILE}" ]; then
      mkdir -p "gettext"  || fail "Unable to create application workspace"
      cd "gettext/"       || fail "Unable to change into the application workspace"

      tar xzvf "${GETTEXT_TARBALL}"   || fail "Unable to unpack application tarball"
      cd "${GETTEXT_SOURCE_DIRNAME}"  || fail "Unable to change into application source directory"

      ./configure ${GETTEXT_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] gettext is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
