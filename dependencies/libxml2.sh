: ${LIBXML2_DEPENDENCIES:=zlib readline}

#-------------------------------------------------------------------------------
install_libxml2()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBXML2_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${ROSE_SH_DEPS_PREFIX}/include/libxml2/libxml/xmlschemas.h" ]; then
      mkdir -p "libxml2"  || exit 1
      cd "libxml2/"    || exit 1

      tar xzvf "${DEPENDENCIES_DIR}/libxml2-2.9.1.tar.gz" || exit 1
      cd "libxml2-2.9.1/" || exit 1

      ./configure \
          --prefix="$ROSE_SH_DEPS_PREFIX" \
          --libdir="$ROSE_SH_DEPS_LIBDIR" \
          \
              --with-zlib="${ROSE_SH_DEPS_PREFIX}" \
              --without-lzma \
              --with-readline="${ROSE_SH_DEPS_PREFIX}" \
              --without-python \
          \
          || exit 1

      make -j${parallelism} || exit 1
      make -j${parallelism} install || exit 1
  else
      info "[SKIP] libxml2 is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
