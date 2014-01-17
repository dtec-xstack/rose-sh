: ${LIBMETALINK_DEPENDENCIES:=expat libxml2}

#-------------------------------------------------------------------------------
install_libmetalink()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBMETALINK_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${ROSE_SH_DEPS_PREFIX}/include/metalink/metalink.h" ]; then
      mkdir -p "libmetalink"  || exit 1
      cd "libmetalink/"    || exit 1

      tar xzvf "${DEPENDENCIES_DIR}/libmetalink-0.1.2.tar.gz" || exit 1
      cd "libmetalink-0.1.2/" || exit 1

      ./configure \
          --prefix="$ROSE_SH_DEPS_PREFIX" \
          --libdir="$ROSE_SH_DEPS_LIBDIR" \
          \
              --with-libexpat \
              --with-libxml2 \
              --with-xml-prefix="${ROSE_SH_DEPS_PREFIX}" \
          \
          || exit 1

      make -j${parallelism} || exit 1
      make -j${parallelism} install || exit 1
  else
      info "[SKIP] libmetalink is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
