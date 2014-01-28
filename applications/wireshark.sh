: ${WIRESHARK_DEPENDENCIES:=
    xcb_proto
    libxcb
    libpixman
    cairo
    atk
    intltool
    at_spi_core
    at_spi_atk
    libc_ares
    libsmi
    harfbuzz
    pango
    gdk_pixbuf
    gtk3
    geoip
    geoip_database
  }
: ${WIRESHARK_CONFIGURE_OPTIONS:=
    --enable-wireshark
    --with-gtk3=yes
    --without-lua
    --without-qt
    --with-gcrypt
    --with-gnutls
    --with-libsmi
    --with-pcap
    --with-zlib
    --without-portaudio
    --without-libcap
    --without-krb5
    --with-cres
    --with-adns
    --with-geoip
  }

#-------------------------------------------------------------------------------
download_wireshark()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_wireshark()
#-------------------------------------------------------------------------------
{
  install_deps ${WIRESHARK_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_wireshark()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_wireshark__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      ./autogen.sh || fail "An error occurred during autotools bootstrapping"

      CC="${ROSE_CC}" \
#      CPPFLAGS="$CPPFLAGS" \
#      CFLAGS="$CFLAGS"  \
#      LDFLAGS="$LDFLAGS"  \
          ./configure \
              --prefix="$(pwd)/install_tree" \
              ${WIRESHARK_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_wireshark__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      ./autogen.sh || fail "An error occurred during autotools bootstrapping"

      CC="${CC}" \
#      CPPFLAGS="$CPPFLAGS" \
#      CFLAGS="$CFLAGS"  \
#      LDFLAGS="$LDFLAGS"  \
          ./configure \
              --prefix="$(pwd)/install_tree" \
              ${WIRESHARK_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_wireshark()
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
