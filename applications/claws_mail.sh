: ${CLAWS_MAIL_DEPENDENCIES:=zlib libetpan}
: ${CLAWS_MAIL_CONFIGURE_OPTIONS:=
    --disable-networkmanager
    --disable-jpilot
    --disable-startup-notification
    --enable-enchant
    --disable-perl-plugin
    --disable-python-plugin
    --enable-gnutls
    --enable-ipv6
    --disable-maemo
    --disable-pdf_viewer-plugin
    --disable-gdata-plugin
    --disable-bogofilter-plugin
    --disable-bsfilter-plugin
    --disable-clamd-plugin
    --disable-notification-plugin
    --disable-fancy-plugin
    --disable-geolocation-plugin
  }

#-------------------------------------------------------------------------------
download_claws_mail()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_claws_mail()
#-------------------------------------------------------------------------------
{
  install_deps ${CLAWS_MAIL_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_claws_mail()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_claws_mail__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CC="${ROSE_CC}" \
          ./configure \
              --prefix="$(pwd)/install_tree"  \
              ${CLAWS_MAIL_CONFIGURE_OPTIONS}      \
              || exit 1
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_claws_mail__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CC="${CC}" \
          ./configure \
              --prefix="$(pwd)/install_tree"  \
              ${CLAWS_MAIL_CONFIGURE_OPTIONS}      \
              || exit 1
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_claws_mail()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      make -j${parallelism}         || exit 1
      make -j${parallelism} install || exit 1
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
