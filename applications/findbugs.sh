: ${FINDBUGS_DEPENDENCIES:=apache_ant ss_ant_rose}
: ${FINDBUGS_CONFIGURE_OPTIONS:=
    -Dcom.pontetec.rosecompiler.use_single_commandline="true"
    -Dcom.pontetec.rosecompiler.translator.arg.rose.skip_commentsAndDirectives=""
  }
: ${FINDBUGS_ANT_TARGET:=build}

#-------------------------------------------------------------------------------
download_findbugs()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_findbugs()
#-------------------------------------------------------------------------------
{
  install_deps ${FINDBUGS_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_findbugs()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_findbugs__rose()
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
            ant "${FINDBUGS_ANT_TARGET}" \
                -verbose \
                -lib "${ROSE_SH_DEPS_PREFIX}/lib" \
                -Dbuild.compiler="com.pontetec.RoseCompilerAdapter" \
                -Dcom.pontetec.rosecompiler.translator="${ROSE_CC}" \
                ${FINDBUGS_CONFIGURE_OPTIONS} \
        || fail "An error occurred during application compilation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_findbugs__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
    /usr/bin/time --format='%E' \
        ant "${FINDBUGS_ANT_TARGET}" \
            ${FINDBUGS_CONFIGURE_OPTIONS} \
    || fail "An error occurred during application compilation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_findbugs()
#-------------------------------------------------------------------------------
{
  info "Application compilation was performed during the configure stage"
}
