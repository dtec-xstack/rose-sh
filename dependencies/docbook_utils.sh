: ${DOCBOOK_UTILS_DEPENDENCIES:=jade docbook_dsssl docbook}
: ${DOCBOOK_UTILS_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${DOCBOOK_UTILS_TARBALL:="docbook-utils-0.6.14.tar.gz"}
: ${DOCBOOK_UTILS_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/docbook_utils.h"}

#-------------------------------------------------------------------------------
install_docbook_utils()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${DOCBOOK_UTILS_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${DOCBOOK_UTILS_INSTALLED_FILE}" ]; then
      rm -rf "./docbook_utils"  || fail "Unable to remove old application workspace"
      mkdir -p "docbook_utils"  || fail "Unable to create application workspace"
      cd "docbook_utils/"       || fail "Unable to change into the application workspace"

      download_tarball "${DOCBOOK_UTILS_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${DOCBOOK_UTILS_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${DOCBOOK_UTILS_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${DOCBOOK_UTILS_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] docbook_utils is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
