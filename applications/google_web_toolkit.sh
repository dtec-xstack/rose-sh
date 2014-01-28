: ${GOOGLE_WEB_TOOLKIT_DEPENDENCIES:=apache_ant ss_ant_rose svn}
: ${GOOGLE_WEB_TOOLKIT_CONFIGURE_OPTIONS:=
    -Dcom.pontetec.rosecompiler.use_single_commandline="true"
  }
: ${GOOGLE_WEB_TOOLKIT_ANT_TARGET:=build}

#-------------------------------------------------------------------------------
download_google_web_toolkit()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_google_web_toolkit()
#-------------------------------------------------------------------------------
{
  install_deps ${GOOGLE_WEB_TOOLKIT_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_google_web_toolkit()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_google_web_toolkit__rose()
#-------------------------------------------------------------------------------
{
  info "Compiling application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      svn checkout http://google-web-toolkit.googlecode.com/svn/tools/ tools \
          || fail "An error occurred during svn checkout of the GWT prerequisite tools and third-party libraries"

      KG__STRIP_PATH="$(pwd)/" \
      KG__REPORT_FAIL="$(pwd)/rose-fails.txt" \
      KG__REPORT_PASS="$(pwd)/rose-passes.txt" \
      GWT_TOOLS="$(pwd)/tools" \
        /usr/bin/time --format='%E' \
            ant "${GOOGLE_WEB_TOOLKIT_ANT_TARGET}" \
                -verbose \
                -lib "${ROSE_SH_DEPS_PREFIX}/lib" \
                -Dbuild.compiler="com.pontetec.RoseCompilerAdapter" \
                -Dcom.pontetec.rosecompiler.translator="${ROSE_CC}" \
                ${GOOGLE_WEB_TOOLKIT_CONFIGURE_OPTIONS} \
        || fail "An error occurred during application compilation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_google_web_toolkit__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      svn checkout http://google-web-toolkit.googlecode.com/svn/tools/ tools \
          || fail "An error occurred during svn checkout of the GWT prerequisite tools and third-party libraries"

    GWT_TOOLS="$(pwd)/tools" \
    /usr/bin/time --format='%E' \
        ant "${GOOGLE_WEB_TOOLKIT_ANT_TARGET}" \
            ${GOOGLE_WEB_TOOLKIT_CONFIGURE_OPTIONS} \
    || fail "An error occurred during application compilation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_google_web_toolkit()
#-------------------------------------------------------------------------------
{
  info "Application compilation was performed during the configure stage"
}
