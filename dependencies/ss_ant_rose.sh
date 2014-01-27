: ${SS_ANT_ROSE_DEPENDENCIES:=apache_ant}
: ${SS_ANT_ROSE_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/lib/rose-compiler-0.1.jar"}

#-------------------------------------------------------------------------------
install_ss_ant_rose()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${SS_ANT_ROSE_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${SS_ANT_ROSE_INSTALLED_FILE}" ]; then
      rm -rf "./ss_ant_rose"  || fail "Unable to create application workspace"
      mkdir -p "ss_ant_rose"  || fail "Unable to create application workspace"
      cd "ss_ant_rose/"       || fail "Unable to change into the application workspace"

      info "Downloading source code"

      set -x
          clone_repository "ss_ant_rose"  || fail "Unable to clone the application source code repository"
          cd "ss_ant_rose-src/"           || fail "Unable to change into application source code directory"

          ant dist || fail "Unable to compile the application"

          cp dist/lib/* "${ROSE_SH_DEPS_PREFIX}/lib" || fail "Unable install the application's library artifacts"
      set +x
  else
      info "[SKIP] ss_ant_rose is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
