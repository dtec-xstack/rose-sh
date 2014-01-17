: ${NCURSES_DEPENDENCIES:=}
: ${NCURSES_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --exec-prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_PREFIX}"
    --enable-pc-files
    --enable-overwrite
    --with-shared
    --with-termlib=tinfo
    --enable-rpath
    --disable-termcap
    --enable-symlinks
    --with-ticlib=tic
    --without-ada
    --without-tests
    --without-profile
    --without-debug
    --enable-echo
    --without-progs
  }
: ${NCURSES_TARBALL:="ncurses-5.9.tar.gz"}
: ${NCURSES_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/ncurses.h"}

#-------------------------------------------------------------------------------
install_ncurses()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${NCURSES_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${NCURSES_INSTALLED_FILE}" ]; then
      rm -rf "./ncurses"                            || fail "Unable to create application workspace"
      mkdir -p "ncurses"                            || fail "Unable to create application workspace"
      cd "ncurses/"                                 || fail "Unable to change into the application workspace"

      download_tarball "${NCURSES_TARBALL}"         || fail "Unable to download application tarball"
      tar xzvf "${NCURSES_TARBALL}"                 || fail "Unable to unpack application tarball"
      cd "$(basename ${NCURSES_TARBALL%.tar.gz})"   || fail "Unable to change into application source directory"

      ./configure ${NCURSES_CONFIGURE_OPTIONS}      || fail "Unable to configure application"

      make -j${parallelism}                         || fail "An error occurred during application compilation"
      make -j${parallelism} install                 || fail "An error occurred during application installation"

      ln -s \
          "${ROSE_SH_DEPS_PREFIX}/lib/libncurses.so" \
          "${ROSE_SH_DEPS_PREFIX}/lib/libtermcap.so"   || fail "Could not create symbolic link"

      ln -s \
          "${ROSE_SH_DEPS_PREFIX}/lib/libncurses.so" \
          "${ROSE_SH_DEPS_PREFIX}/lib/libtermcap.so.2" || fail "Could not create symbolic link"
  else
      info "[SKIP] ncurses is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
