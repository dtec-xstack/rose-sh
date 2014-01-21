# Installation instructions: http://www.linuxfromscratch.org/blfs/view/svn/pst/sgml-common.html

: ${SGML_COMMON_DEPENDENCIES:=}
: ${SGML_COMMON_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --sysconfdir="${ROSE_SH_DEPS_PREFIX}/etc"
  }
: ${SGML_COMMON_TARBALL:="sgml-common-0.6.3.tgz"}
: ${SGML_COMMON_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/share/sgml/xml.dcl"}

#-------------------------------------------------------------------------------
install_sgml_common()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${SGML_COMMON_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${SGML_COMMON_INSTALLED_FILE}" ]; then
      rm -rf "./sgml_common"  || fail "Unable to remove old application workspace"
      mkdir -p "sgml_common"  || fail "Unable to create application workspace"
      cd "sgml_common/"       || fail "Unable to change into the application workspace"

      download_tarball "${SGML_COMMON_TARBALL}"     || fail "Unable to download application tarball"
      tar xzvf "${SGML_COMMON_TARBALL}"             || fail "Unable to unpack application tarball"
      cd "$(basename ${SGML_COMMON_TARBALL%.tgz})"  || fail "Unable to change into application source directory"

      patch -Np1 -i \
          "${DEPENDENCIES_DIR}/patches/sgml-common-0.6.3-manpage-1.patch" \
      || fail "Failed to apply patch"

      autoreconf -f -i || fail "An error occurred during application autoreconf"

      ./configure \
          ${SGML_COMMON_CONFIGURE_OPTIONS} \
      || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] sgml_common is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
