: ${HSQLDB_DEPENDENCIES:=apache_ant ss_ant_rose}
: ${HSQLDB_CONFIGURE_OPTIONS:=
    -Dcom.pontetec.rosecompiler.use_single_commandline="true"
    -Dcom.pontetec.rosecompiler.translator.arg.rose.skip_commentsAndDirectives=""
  }
: ${HSQLDB_ANT_TARGET:=hsqldb}

#-------------------------------------------------------------------------------
download_hsqldb()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_hsqldb()
#-------------------------------------------------------------------------------
{
  install_deps ${HSQLDB_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_hsqldb()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_hsqldb__rose()
#-------------------------------------------------------------------------------
{
  info "Compiling application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      KG__STRIP_PATH="$(pwd)/" \
      KG__REPORT_FAIL="$(pwd)/rose-fails.txt" \
      KG__REPORT_PASS="$(pwd)/rose-passes.txt" \
        /usr/bin/time --format='%E' \
            ant "${HSQLDB_ANT_TARGET}" \
                -verbose \
                -lib "${ROSE_SH_DEPS_PREFIX}/lib" \
                -Dbuild.compiler="com.pontetec.RoseCompilerAdapter" \
                -Dcom.pontetec.rosecompiler.translator="${ROSE_CC}" \
                -buildfile build/build.xml \
                ${HSQLDB_CONFIGURE_OPTIONS} \
        || fail "An error occurred during application compilation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_hsqldb__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
    /usr/bin/time --format='%E' \
        ant "${HSQLDB_ANT_TARGET}" \
            -buildfile build/build.xml \
            ${HSQLDB_CONFIGURE_OPTIONS} \
    || fail "An error occurred during application compilation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_hsqldb()
#-------------------------------------------------------------------------------
{
  info "Application compilation was performed during the configure stage"
}
