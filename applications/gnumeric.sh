: ${GNUMERIC_DEPENDENCIES:=zlib libgsf librsvg goffice gtk3}
: ${GNUMERIC_CONFIGURE_OPTIONS:=
  --with-gtk
  --without-gda
  --without-perl
  --without-python
  }

#-------------------------------------------------------------------------------
download_gnumeric()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_gnumeric()
#-------------------------------------------------------------------------------
{
  install_deps ${GNUMERIC_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_gnumeric()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_gnumeric__rose()
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
              ${GNUMERIC_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_gnumeric__gcc()
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
              ${GNUMERIC_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_gnumeric()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
