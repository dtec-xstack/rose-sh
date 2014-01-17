: ${DOCBOOK_DEPENDENCIES:=}
: ${DOCBOOK_CONFIGURE_OPTIONS:=
  }
: ${DOCBOOK_TARBALL:="${DEPENDENCIES_DIR}/docbook-3.1.tar.gz"}
: ${DOCBOOK_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/docbook/docbook.h"}

#-------------------------------------------------------------------------------
install_docbook()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${DOCBOOK_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${DOCBOOK_INSTALLED_FILE}" ]; then
      mkdir -p "docbook"  || fail "Unable to create application workspace"
      cd "docbook/"       || fail "Unable to change into the application workspace"

      tar xzvf "${DOCBOOK_TARBALL}"               || fail "Unable to unpack application tarball"
      cd "$(basename ${DOCBOOK_TARBALL%.tar.gz})" || fail "Unable to change into application source directory"

      # Installation: http://www.linuxfromscratch.org/blfs/view/svn/pst/sgml-dtd-3.html
      #
      # 1. Removes the ENT definitions from the catalog file
      # 2. Replaces the DTDDECL catalog entry, which is not supported by Linux
      #    SGML tools, with the SGMLDECL catalog entry
      #
      sed -i -e '/ISO 8879/d' \
             -e 's|DTDDECL "-//OASIS//DTD DocBook V3.1//EN"|SGMLDECL|g' \
             docbook.cat || fail "Failed sed patching"

      install -v -d -m755 \
          "${ROSE_SH_DEPS_PREFIX}/share/sgml/docbook/sgml-dtd-3.1" \
      || fail "Failed to install sgml-dtd-3.1"

      install -v docbook.cat \
          "${ROSE_SH_DEPS_PREFIX}/share/sgml/docbook/sgml-dtd-3.1/catalog" \
      || fail "Failed to install docbook.cat"

      cp -v -af *.dtd *.mod *.dcl \
          "${ROSE_SH_DEPS_PREFIX}/share/sgml/docbook/sgml-dtd-3.1" \
      || fail "Failed to cp files to sgml-dtd-3.1"

      install-catalog --add \
          "${ROSE_SH_DEPS_PREFIX}/etc/sgml/sgml-docbook-dtd-3.1.cat" \
          "${ROSE_SH_DEPS_PREFIX}/share/sgml/docbook/sgml-dtd-3.1/catalog" \
      || fail "Failed to install-catalog"

      install-catalog --add \
         "${ROSE_SH_DEPS_PREFIX}/etc/sgml/sgml-docbook-dtd-3.1.cat" \
         "${ROSE_SH_DEPS_PREFIX}/etc/sgml/sgml-docbook.cat" \
      || fail "Failed to install-catalog"

  else
      info "[SKIP] docbook is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
