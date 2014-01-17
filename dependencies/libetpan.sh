: ${LIBETPAN_DEPENDENCIES:=openssl zlib cyrus_sasl db expat curl}

#-------------------------------------------------------------------------------
install_libetpan()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBETPAN_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${ROSE_SH_DEPS_PREFIX}/include/libetpan.h" ]; then
      mkdir -p "libetpan"  || exit 1
      cd "libetpan/"    || exit 1

      tar xjvf "${DEPENDENCIES_DIR}/libetpan-1.2.tar.bz2" || exit 1
      cd "libetpan-1.2/" || exit 1

      ./configure \
          --prefix="$ROSE_SH_DEPS_PREFIX" \
          --libdir="$ROSE_SH_DEPS_LIBDIR" \
          \
              --with-openssl="${ROSE_SH_DEPS_PREFIX}" \
              --with-sasl="${ROSE_SH_DEPS_PREFIX}" \
              --with-curl="${ROSE_SH_DEPS_PREFIX}" \
              --with-expat="${ROSE_SH_DEPS_PREFIX}" \
              --with-zlib \
          \
          || exit 1

      make -j${parallelism} || exit 1
      make -j${parallelism} install || exit 1
  else
      info "[SKIP] libetpan is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
