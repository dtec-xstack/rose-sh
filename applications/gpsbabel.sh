: ${GPSBABEL_DEPENDENCIES:=zlib expat}
: ${GPSBABEL_CONFIGURE_OPTIONS:=
    --with-zlib=system
    --with-expathdr="${ROSE_SH_DEPS_PREFIX}/include"
    --with-libexpat="${ROSE_SH_DEPS_PREFIX}/lib"
    --disable-csv
  }

#-------------------------------------------------------------------------------
download_gpsbabel()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_gpsbabel()
#-------------------------------------------------------------------------------
{
  install_deps ${GPSBABEL_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_gpsbabel()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_gpsbabel__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CC="${ROSE_CC}" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS"  \
      LDFLAGS="$LDFLAGS"  \
          ./configure \
              --prefix="$(pwd)/install_tree" \
              ${GPSBABEL_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_gpsbabel__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CC="${CC}" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS"  \
      LDFLAGS="$LDFLAGS"  \
          ./configure \
              --prefix="$(pwd)/install_tree" \
              ${GPSBABEL_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_gpsbabel()
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
