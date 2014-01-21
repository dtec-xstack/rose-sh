: ${GIT_DEPENDENCIES:=curl openssl expat zlib}
: ${GIT_CONFIGURE_OPTIONS:=
    --with-openssl
    --with-curl
    --with-expat
    --with-libpcre
    --with-gitconfig
    --with-gitattributes
    --with-shell="/bin/bash"
    --without-tcltk
    --with-zlib="${ROSE_SH_DEPS_PREFIX}"}

#-------------------------------------------------------------------------------
download_git()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_git()
#-------------------------------------------------------------------------------
{
  install_deps ${GIT_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_git()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_git__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      make configure || exit 1
      CC="${ROSE_CC}"                           \
          ./configure                           \
              --prefix="$(pwd)/install_tree"    \
              ${GIT_CONFIGURE_OPTIONS}          \
              || exit 1
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_git__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      make configure || exit 1
      CC="${CC}"                                \
          ./configure                           \
              --prefix="$(pwd)/install_tree"    \
              ${GIT_CONFIGURE_OPTIONS}          \
              || exit 1
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_git()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      make V=1 -j${parallelism}  || exit 1
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
