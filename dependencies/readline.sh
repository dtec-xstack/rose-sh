: ${READLINE_DEPENENCIES:=ncurses}

#-------------------------------------------------------------------------------
install_readline()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${READLINE_DEPENENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${ROSE_SH_DEPS_PREFIX}/include/readline/readline.h" ]; then
      mkdir -p "readline"  || exit 1
      cd "readline/"    || exit 1

      tar xzvf "${DEPENDENCIES_DIR}/readline-6.2.tar.gz" || exit 1
      cd "readline-6.2/" || exit 1

      ./configure \
          --prefix="$ROSE_SH_DEPS_PREFIX" \
          --exec-prefix="$ROSE_SH_DEPS_PREFIX" \
          --libdir="$ROSE_SH_DEPS_LIBDIR" \
          --with-curses || exit 1

      make -j${parallelism} || exit 1
      make -j${parallelism} install || exit 1
  else
      info "[SKIP] readline is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
