: ${XMLTO_DEPENDENCIES:=libxml2 libxslt docbook-xml docbook-xsl}
: ${XMLTO_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${XMLTO_TARBALL:="xmlto-0.0.25.tar.gz"}
: ${XMLTO_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/xmlto.h"}

#-------------------------------------------------------------------------------
install_xmlto()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${XMLTO_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${XMLTO_INSTALLED_FILE}" ]; then
      rm -rf "./xmlto"                           || fail "Unable to remove old application workspace"
      mkdir -p "xmlto"                           || fail "Unable to create application workspace"
      cd "xmlto/"                                || fail "Unable to change into the application workspace"

      download_tarball "${XMLTO_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${XMLTO_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${XMLTO_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${XMLTO_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] xmlto is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
