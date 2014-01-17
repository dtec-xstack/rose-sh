: ${APR_UTIL_DEPENDENCIES:=expat apr gdbm openssl}

#-------------------------------------------------------------------------------
install_apr_util()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${APR_UTIL_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${ROSE_SH_DEPS_PREFIX}/lib/aprutil.exp" ]; then
      mkdir -p "apr_util"  || exit 1
      cd "apr_util/"    || exit 1

      tar xzvf "${DEPENDENCIES_DIR}/apr-util-1.5.2.tar.gz" || exit 1
      cd "apr-util-1.5.2/" || exit 1

      ./configure \
          --prefix="$ROSE_SH_DEPS_PREFIX" \
          --libdir="$ROSE_SH_DEPS_LIBDIR" \
          \
              --with-apr="${ROSE_SH_DEPS_PREFIX}" \
              --with-openssl="${ROSE_SH_DEPS_PREFIX}" \
              --with-expat="${ROSE_SH_DEPS_PREFIX}" \
              --with-dbm=db \
              --with-berkeley-db="${ROSE_SH_DEPS_PREFIX}" \
              --with-crypto \
          \
          || exit 1

      make -j${parallelism} || exit 1
      make -j${parallelism} install || exit 1
  else
      info "[SKIP] apr_util is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
