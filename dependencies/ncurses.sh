: ${NCURSES_DEPENDENCIES:=}

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
  if [ ! -f "${ROSE_SH_DEPS_PREFIX}/include/ncurses.h" ]; then
      mkdir -p "ncurses"  || exit 1
      cd "ncurses/"    || exit 1

      tar xzvf "${DEPENDENCIES_DIR}/ncurses-5.9.tar.gz" || exit 1
      cd "ncurses-5.9/" || exit 1

      ./configure \
          --prefix="$ROSE_SH_DEPS_PREFIX" \
          --libdir="$ROSE_SH_DEPS_LIBDIR" \
          \
          --enable-pc-files \
          --enable-overwrite \
          --with-shared \
          --with-termlib=tinfo \
          --enable-rpath \
          --disable-termcap \
          --enable-symlinks \
          --with-ticlib=tic \
          --without-ada \
          --without-tests \
          --without-profile \
          --without-debug \
          --enable-echo \
          --without-progs || exit 1

      make -j${parallelism} || exit 1
      make -j${parallelism} install || exit 1

      ln -s \
          "${ROSE_SH_DEPS_PREFIX}/lib/libncurses.so" \
          "${ROSE_SH_DEPS_PREFIX}/lib/libtermcap.so"   || exit 1

      ln -s \
          "${ROSE_SH_DEPS_PREFIX}/lib/libncurses.so" \
          "${ROSE_SH_DEPS_PREFIX}/lib/libtermcap.so.2" || exit 1
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
