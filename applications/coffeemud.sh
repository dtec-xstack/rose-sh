: ${COFFEEMUD_DEPENDENCIES:=apache_ant ss_ant_rose}
: ${COFFEEMUD_CONFIGURE_OPTIONS:=
    -Dcom.pontetec.rosecompiler.use_single_commandline="true"
    -Dcom.pontetec.rosecompiler.translator.arg.rose.skip_commentsAndDirectives=""
  }
: ${COFFEEMUD_ANT_TARGET:=compile}

#-------------------------------------------------------------------------------
download_coffeemud()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_coffeemud()
#-------------------------------------------------------------------------------
{
  install_deps ${COFFEEMUD_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_coffeemud()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_coffeemud__rose()
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
            ant "${COFFEEMUD_ANT_TARGET}" \
                -verbose \
                -lib "${ROSE_SH_DEPS_PREFIX}/lib" \
                -Dbuild.compiler="com.pontetec.RoseCompilerAdapter" \
                -Dcom.pontetec.rosecompiler.translator="${ROSE_CC}" \
                ${COFFEEMUD_CONFIGURE_OPTIONS} \
        || fail "An error occurred during application compilation"

      JAVAC="${ROSE_CC}" \
      JAVAC_FLAGS="-verbose -rose:java:classpath \".:./lib/js.jar:./lib/jzlib.jar\"" \
          make all -j${parallelism} || fail "An error occurred during application compilation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_coffeemud__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${JAVAC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
    /usr/bin/time --format='%E' \
        ant "${COFFEEMUD_ANT_TARGET}" \
            ${COFFEEMUD_CONFIGURE_OPTIONS} \
    || fail "An error occurred during application compilation"

    JAVAC="${JAVAC}" \
        make all -j${parallelism} || fail "An error occurred during application compilation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_coffeemud()
#-------------------------------------------------------------------------------
{
  info "Application compilation was performed during the configure stage"
}
