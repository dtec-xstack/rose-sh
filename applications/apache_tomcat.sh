: ${APACHE_TOMCAT_DEPENDENCIES:=apache_ant ss_ant_rose}
: ${APACHE_TOMCAT_CONFIGURE_OPTIONS:=
    -Dcom.pontetec.rosecompiler.use_single_commandline="true"
  }
: ${APACHE_TOMCAT_ANT_TARGET:=deploy}

#-------------------------------------------------------------------------------
download_apache_tomcat()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_apache_tomcat()
#-------------------------------------------------------------------------------
{
  install_deps ${APACHE_TOMCAT_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_apache_tomcat()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_apache_tomcat__rose()
#-------------------------------------------------------------------------------
{
  info "Compiling application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      ant download-compile || fail "An error occurred during download-compile"

      KG__STRIP_PATH="$(pwd)/" \
      KG__REPORT_FAIL="$(pwd)/rose-fails.txt" \
      KG__REPORT_PASS="$(pwd)/rose-passes.txt" \
        /usr/bin/time --format='%E' \
            ant "${APACHE_TOMCAT_ANT_TARGET}" \
                -verbose \
                -lib "${ROSE_SH_DEPS_PREFIX}/lib" \
                -Dbuild.compiler="com.pontetec.RoseCompilerAdapter" \
                -Dcom.pontetec.rosecompiler.translator="${ROSE_CC}" \
                ${APACHE_TOMCAT_CONFIGURE_OPTIONS} \
        || fail "An error occurred during application compilation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_apache_tomcat__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
    ant download-compile || fail "An error occurred during download-compile"

    /usr/bin/time --format='%E' \
        ant "${APACHE_TOMCAT_ANT_TARGET}" \
            ${APACHE_TOMCAT_CONFIGURE_OPTIONS} \
    || fail "An error occurred during application compilation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_apache_tomcat()
#-------------------------------------------------------------------------------
{
  info "Application compilation was performed during the configure stage"
}
