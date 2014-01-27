: ${APACHE_ANT_DEPENDENCIES:=}
: ${APACHE_ANT_TARBALL:="apache-ant-1.9.3-bin.tar.gz"}
: ${APACHE_ANT_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/bin/ant"}

#-------------------------------------------------------------------------------
install_apache_ant()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${APACHE_ANT_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${APACHE_ANT_INSTALLED_FILE}" ]; then
      rm -rf "./apache_ant"                           || fail "Unable to create application workspace"
      mkdir -p "apache_ant"                           || fail "Unable to create application workspace"
      cd "apache_ant/"                                || fail "Unable to change into the application workspace"

      download_tarball "${APACHE_ANT_TARBALL}"            || fail "Unable to download application tarball"
      tar xzvf "${APACHE_ANT_TARBALL}"                    || fail "Unable to unpack application tarball"
      cd "$(basename ${APACHE_ANT_TARBALL%-bin.tar.gz})"  || fail "Unable to change into application source directory"


      cp -r bin/* "${ROSE_SH_DEPS_PREFIX}/bin" || fail "Unable to install application binaries"
      cp -r etc/* "${ROSE_SH_DEPS_PREFIX}/etc" || fail "Unable to install application etc files"
      cp -r lib/* "${ROSE_SH_DEPS_PREFIX}/lib" || fail "Unable to install application lib files"
  else
      info "[SKIP] apache_ant is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
