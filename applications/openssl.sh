: ${OPENSSL_DEPENDENCIES:=zlib}
: ${OPENSSL_CONFIGURE_OPTIONS:=
    shared
  }

#-------------------------------------------------------------------------------
download_openssl()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_openssl()
#-------------------------------------------------------------------------------
{
  install_deps ${OPENSSL_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_openssl()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_openssl__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS"  \
      LDFLAGS="$LDFLAGS"  \
      CC="${ROSE_CC} ${LDFLAGS}" \
          ./config \
              --prefix="$(pwd)/install_tree" \
              ${OPENSSL_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_openssl__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS"  \
      LDFLAGS="$LDFLAGS"  \
      CC="${CC} ${LDFLAGS}" \
          ./config \
              --prefix="$(pwd)/install_tree" \
              ${OPENSSL_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_openssl()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      make -j${parallelism}         || fail "An error occurred during application compilation"
# TODO:
#      make -j${parallelism} install || fail "An error occurred during application installation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
