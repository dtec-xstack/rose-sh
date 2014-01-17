: ${GTKSPELL_DEPENDENCIES:=glib atk cairo pango enchant fontconfig freetype gtk2 zlib}
: ${GTKSPELL_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${GTKSPELL_TARBALL:="${DEPENDENCIES_DIR}/gtkspell-2.0.16.tar.gz"}
: ${GTKSPELL_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/gtkspell.h"}

#-------------------------------------------------------------------------------
install_gtkspell()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${GTKSPELL_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${GTKSPELL_INSTALLED_FILE}" ]; then
      mkdir -p "gtkspell"  || fail "Unable to create application workspace"
      cd "gtkspell/"       || fail "Unable to change into the application workspace"

      tar xzvf "${GTKSPELL_TARBALL}"               || fail "Unable to unpack application tarball"
      cd "$(basename ${GTKSPELL_TARBALL%.tar.gz})" || fail "Unable to change into application source directory"

      ./configure ${GTKSPELL_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] gtkspell is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
