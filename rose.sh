#!/usr/bin/env bash
set -e

#-------------------------------------------------------------------------------
# Set defaults
#-------------------------------------------------------------------------------
: ${ROSE_CC:="identityTranslator"}
: ${CC:="gcc"}
: ${workspace:="$(pwd)/workspace"}
: ${parallelism:=1}
: ${application:=$1}
: ${application_workspace:="${workspace}/${application}"}
: ${application_log:="${application_workspace}/output.txt-$$"}
#-------------------------------------------------------------------------------
: ${TARBALL_MIRROR_URLS:=
  https://bitbucket.org/rose-compiler/rose-sh/downloads
  http://portal.nersc.gov/project/dtec/tarballs/dependencies
  }
#-------------------------------------------------------------------------------

export ROSE_SH_HOME="$(cd "$(dirname "$0")" && pwd)"

export APPLICATIONS_DIR="${ROSE_SH_HOME}/applications"
export APPLICATION_SCRIPT="${APPLICATIONS_DIR}/${application}.sh"

#-------------------------------------------------------------------------------
# Dependencies
#-------------------------------------------------------------------------------
export DEPENDENCIES_DIR="${ROSE_SH_HOME}/dependencies"
export DEPENDENCIES_LIST="$(ls ${DEPENDENCIES_DIR}/*.sh)"

: ${ROSE_SH_DEPS_PREFIX:="${DEPENDENCIES_DIR}/installation"}
export ROSE_SH_DEPS_LIBDIR="${ROSE_SH_DEPS_PREFIX}/lib"

: ${LDFLAGS:=-L"${ROSE_SH_DEPS_PREFIX}/lib" -L"${ROSE_SH_DEPS_PREFIX}/lib64" -Wl,-z,relro -Wl,-R"${ROSE_SH_DEPS_PREFIX}/lib" -Wl,-R"${ROSE_SH_DEPS_PREFIX}"/lib "-L${LIBTOOL_HOME}/lib"}
: ${CFLAGS:=-I"${ROSE_SH_DEPS_PREFIX}/include" "-I${LIBTOOL_HOME}/include"}
: ${CPPFLAGS:=-I"${ROSE_SH_DEPS_PREFIX}/include" "-I${LIBTOOL_HOME}/include"}
export PKG_CONFIG_PATH="${ROSE_SH_DEPS_PREFIX}/lib:${ROSE_SH_DEPS_PREFIX}/lib/pkgconfig:${ROSE_SH_DEPS_PREFIX}/lib64:${ROSE_SH_DEPS_PREFIX}/lib64/pkgconfig:${PKG_CONFIG_PATH}"
export PATH="${ROSE_SH_DEPS_PREFIX}/bin:${ROSE_SH_DEPS_PREFIX}/sbin:${PATH}"
export LD_LIBRARY_PATH="${ROSE_SH_DEPS_PREFIX}/lib:${ROSE_SH_DEPS_PREFIX}/lib64:${LD_LIBRARY_PATH}"

#-------------------------------------------------------------------------------
rosesh__install_dep_setup()
#-------------------------------------------------------------------------------
{
  mkdir -p "${ROSE_SH_DEPS_PREFIX}/workspace" || fail "Could not create the installation workspace directory"
  pushd "${ROSE_SH_DEPS_PREFIX}/workspace"    || fail "Could not cd into the installation workspace directory"
}

#-------------------------------------------------------------------------------
rosesh__install_dep_teardown()
#-------------------------------------------------------------------------------
{
  popd || exit 1
}

#-------------------------------------------------------------------------------
install_deps() # $*=dependencies
#-------------------------------------------------------------------------------
{
  declare -r DEPENDENCIES="$*"

  info "[Dependencies] External dependencies: '${DEPENDENCIES}'"

  if [ -z "${DEPENDENCIES}" ]; then
    return 0
  else
    for dep in ${DEPENDENCIES}; do
      (

            install_${dep} || exit 1

      ) 2>&1 | while read; do echo "[install_dep=${dep}] ${REPLY}"; done
      [ ${PIPESTATUS[0]} -ne 0 ] && fail "Failed installation of dependency '${dep}'" || true
    done
  fi
}

#-------------------------------------------------------------------------------
# Utilities
#-------------------------------------------------------------------------------
info() { printf "[INFO] $*\n" ; return 0 ; }
fail() { printf "\n[FATAL] $*\n" 1>&2 ; exit 1 ; }

download_tarball()
{
  local tarball="$1"
  [ -z "${tarball}" ] && fail "Usage: download_tarball <tarball>"

  for mirror_url in ${TARBALL_MIRROR_URLS}; do
    local tarball_url="${mirror_url}/${tarball}"

    info "Attempting tarball download: '${tarball_url}'"

    wget --no-check-certificate "${tarball_url}"
    if test $? -eq 0; then
        return 0
    else
        info "Could not download '${tarball}' from mirror '${mirror_url}'"
        continue
    fi
  done

  fail "Unable to download '${tarball}'"
}

#-------------------------------------------------------------------------------
# Source dependencies install functions
#-------------------------------------------------------------------------------
for dependency in $DEPENDENCIES_LIST; do
    info "Sourcing dependency script '${dependency}'"
    source "${dependency}" || exit 1
done

#-------------------------------------------------------------------------------
phase_1()
#-------------------------------------------------------------------------------
{
  info "Performing Phase 1"

  mkdir -p "${application_workspace}/phase_1" || fail "phase_1::create_workspace failed"
  pushd "${application_workspace}/phase_1"    || fail "phase_1::cd_into_workspace failed"
      "install_deps_${application}"           || fail "phase_1::install_deps failed with status='$?'"

      "download_${application}"               || fail "phase_1::download failed with status='$?'"
      "patch_${application}"                  || fail "phase_1::patch failed with status='$?'"
      "configure_${application}__rose"        || fail "phase_1::configure_with_rose failed with status='$?'"
      "compile_${application}"                || fail "phase_1::compile failed with status='$?'"
  popd
}

#-------------------------------------------------------------------------------
phase_2()
#-------------------------------------------------------------------------------
{
  info "Performing Phase 2"

  mkdir -p "${application_workspace}/phase_2" || fail "phase_2::create_workspace failed"
  pushd "${application_workspace}/phase_2"    || fail "phase_2::cd_into_workspace failed"
      "install_deps_${application}"           || fail "phase_2::install_deps failed with status='$?'"

      "download_${application}"               || fail "phase_2::download failed with status='$?'"
      "patch_${application}"                  || fail "phase_2::patch failed with status='$?'"

      # Replace application source code files with ROSE translated source code files
      "${ROSE_SH_HOME}/opt/stage_rose.sh" -f \
          "${application_workspace}/phase_1/${application}-src" \
          "${application_workspace}/phase_2/${application}-src" \
                                              || fail "phase2::stage_rose.sh failed"

      # Save the diff with the updated ROSE files
      pushd "${application_workspace}/phase_2/${application}-src" || fail "phase_2::cd_into_source_dir failed"
          git diff --patch > "add_rose_translated_sources.patch"  || fail "phase_2::generate_diff_patch failed"
          git add "add_rose_translated_sources.patch"             || fail "phase_2::git_add_diff_patch failed"
          git commit -a -m "Add ROSE translated sources"          || fail "phase_2::git_commit_rose_diff failed"
      popd
      tar czvf \
          "${application_workspace}/phase_2/${application}-src-rose.tgz" \
          "${application_workspace}/phase_2/${application}-src"   || fail "phase_2::create_application_tarball_containing_rose_sources failed"

      "configure_${application}__gcc"   || fail "phase_2::configure_with_gcc failed with status='$?'"
      "compile_${application}"          || fail "phase_2::compile failed with status='$?'"
  popd
}

#-------------------------------------------------------------------------------
main()
#-------------------------------------------------------------------------------
{
    info "Performing main()"

    #-------------------------------------------------------------------------------
    # Source application build function
    #-------------------------------------------------------------------------------
    if [ -z "${APPLICATION_SCRIPT}" -o ! -f "${APPLICATION_SCRIPT}" ]; then
        fail "Application script does not exist: '${APPLICATION_SCRIPT}'"
    else
        info "Sourcing application script '${APPLICATION_SCRIPT}'"
        source "${APPLICATION_SCRIPT}" || exit 1
    fi

      (

          phase_1 || exit 1

      ) 2>&1 | while read; do echo "[Phase 1] ${REPLY}"; done
      [ ${PIPESTATUS[0]} -ne 0 ] && fail "Failed during Phase 1 of ${application}" || true

      (

          phase_2 || exit 1

      ) 2>&1 | while read; do echo "[Phase 2] ${REPLY}"; done
      [ ${PIPESTATUS[0]} -ne 0 ] && fail "Failed during Phase 2 of ${application}" || true

    popd
}

# Build in a separate workspace, so we don't pollute the user's current directory.
rm -rf "${application_workspace}"   || fail "main::remove_workspace failed"
mkdir -p "${application_workspace}" || fail "main::create_workspace failed"
pushd "${application_workspace}"    || fail "main::cd_into_workspace failed"

#-------------------------------------------------------------------------------
# Entry point for program execution
#-------------------------------------------------------------------------------
(

    if [ "x$1" = "xinstall-deps" ]; then
      shift
      install_deps $* || fail "Could not install deps '$*'"
      echo "SUCCESS"
      exit 0
    fi

    main || fail "Main program execution failed"

)  2>&1 | while read; do echo "[INFO] [$(date +%Y%m%d-%H:%M:%S)] [${application}] ${REPLY}"; done | tee "${application_log}"
[ ${PIPESTATUS[0]} -ne 0 ] && fail "Failed during execution of '${application}' tests. See log output: '${application_log}'" || true

info "-------------------------------------------------------------------------------"
info "SUCCESS"
exit 0
