: ${PCRE_DEPENDENCIES:=zlib bzip2 readline}

#-------------------------------------------------------------------------------
install_pcre()
#-------------------------------------------------------------------------------
{
  info "Installing pcre"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${PCRE_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${ROSE_SH_DEPS_PREFIX}/include/pcre.h" ]; then
      mkdir -p "pcre" || exit 1
      cd "pcre/" || exit 1

      tar xzvf "${DEPENDENCIES_DIR}/pcre-8.31.tar.gz" || exit 1
      cd "pcre-8.31/" || exit 1

      CC="${CC} ${LDFLAGS}" \
          ./configure \
              --prefix="$ROSE_SH_DEPS_PREFIX" \
              --libdir="$ROSE_SH_DEPS_LIBDIR" \
              \
              --exec-prefix="$ROSE_SH_DEPS_PREFIX" \
              --enable-unicode-properties \
              --enable-utf \
              --enable-pcregrep-libz \
              --enable-pcregrep-libbz2 \
              --enable-pcretest-libreadline || exit 1

      make -j${parallelism} || exit 1
      make -j${parallelism} install || exit 1
  else
      info "[SKIP] pcre is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
