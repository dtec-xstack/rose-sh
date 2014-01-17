: ${ZLIB_DEPENDENCIES:=}

#-------------------------------------------------------------------------------
install_zlib()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${ZLIB_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${ROSE_SH_DEPS_PREFIX}/include/zlib.h" ]; then
      mkdir -p "zlib"  || exit 1
      cd "zlib/"    || exit 1

      tar xzvf "${DEPENDENCIES_DIR}/zlib-1.2.8.tar.gz" || exit 1
      cd "zlib-1.2.8/" || exit 1

      ./configure \
          --prefix="$ROSE_SH_DEPS_PREFIX" \
          --libdir="$ROSE_SH_DEPS_LIBDIR" || exit 1

      make -j${parallelism} || exit 1
      make -j${parallelism} install || exit 1
  else
      info "[SKIP] zlib is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
