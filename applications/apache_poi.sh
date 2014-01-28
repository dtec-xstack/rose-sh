: ${APACHE_POI_DEPENDENCIES:=apache_ant ss_ant_rose}
: ${APACHE_POI_CONFIGURE_OPTIONS:=
    -Dcom.pontetec.rosecompiler.use_single_commandline="true"
  }
: ${APACHE_POI_ANT_TARGET:=compile}

#-------------------------------------------------------------------------------
download_apache_poi()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_apache_poi()
#-------------------------------------------------------------------------------
{
  install_deps ${APACHE_POI_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_apache_poi()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_apache_poi__rose()
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
            ant "${APACHE_POI_ANT_TARGET}" \
                -verbose \
                -lib "${ROSE_SH_DEPS_PREFIX}/lib" \
                -Dbuild.compiler="com.pontetec.RoseCompilerAdapter" \
                -Dcom.pontetec.rosecompiler.translator="${ROSE_CC}" \
                ${APACHE_POI_CONFIGURE_OPTIONS} \
        || fail "An error occurred during application compilation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_apache_poi__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
    /usr/bin/time --format='%E' \
        ant "${APACHE_POI_ANT_TARGET}" \
            ${APACHE_POI_CONFIGURE_OPTIONS} \
    || fail "An error occurred during application compilation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_apache_poi()
#-------------------------------------------------------------------------------
{
  info "Application compilation was performed during the configure stage"
}
