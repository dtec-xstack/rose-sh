: ${CURL_DEPENDENCIES:=openssl zlib libidn openldap libssh2 libmetalink}

#-------------------------------------------------------------------------------
install_curl()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${CURL_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${ROSE_SH_DEPS_PREFIX}/include/curl/curl.h" ]; then
      mkdir -p "curl"  || exit 1
      cd "curl/"    || exit 1

      tar xzvf "${DEPENDENCIES_DIR}/curl-7.32.0.tar.gz" || exit 1
      cd "curl-7.32.0/" || exit 1

      ./configure \
          --prefix="$ROSE_SH_DEPS_PREFIX" \
          --libdir="$ROSE_SH_DEPS_LIBDIR" \
          \
              --with-ssl="${ROSE_SH_DEPS_PREFIX}" \
              --with-libssh2="${ROSE_SH_DEPS_PREFIX}" \
              --with-libidn="${ROSE_SH_DEPS_PREFIX}" \
              --disable-ntlm-wb \
              --with-zlib="${ROSE_SH_DEPS_PREFIX}" \
              --with-libmetalink="${ROSE_SH_DEPS_PREFIX}" \
              --without-winssl \
              --without-darwinssl \
              --without-gnutls \
              --without-polarssl \
              --without-cyassl \
              --without-nss \
              --without-axtls \
              --without-librtmp \
              --without-winidn \
          \
          || exit 1

      make -j${parallelism} || exit 1
      make -j${parallelism} install || exit 1
  else
      info "[SKIP] curl is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
