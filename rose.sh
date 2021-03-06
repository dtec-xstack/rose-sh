#!/usr/bin/env bash
set -e

#-------------------------------------------------------------------------------
# Set defaults
#-------------------------------------------------------------------------------
: ${ROSE_CC:="$(which identityTranslator)"}
: ${CC:="gcc"}
: ${JAVAC:="javac"}
: ${workspace:="$(pwd)/workspace"}
: ${parallelism:=1}
: ${application:=$1}
: ${application_workspace:="${workspace}/${application}"}
: ${application_log:="${application_workspace}/output.txt-$$"}
#-------------------------------------------------------------------------------
: ${REPOSITORY_MIRROR_URLS:=
  https://bitbucket.org/rose-compiler
  rose-dev@rosecompiler1.llnl.gov:rose/c
  }
: ${TARBALL_MIRROR_URLS:=
  http://hudson-rose-30:8080/userContent/tarballs/dependencies
  https://rosecompiler1.llnl.gov:8443/jenkins-edg4x/userContent/tarballs/dependencies
  http://portal.nersc.gov/project/dtec/tarballs/dependencies
  https://bitbucket.org/rose-compiler/rose-sh/downloads
  }
#-------------------------------------------------------------------------------

export ROSE_SH_HOME="$(cd "$(dirname "$0")" && pwd)"

export APPLICATIONS_DIR="${ROSE_SH_HOME}/applications"
export APPLICATION_SCRIPT="${APPLICATIONS_DIR}/${application}.sh"
export APPLICATIONS_LIST="$(ls ${APPLICATIONS_DIR}/*.sh | sed 's/\.sh//' | xargs -I{} basename {} | sort)"

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
export PATH="${ROSE_SH_HOME}/opt:${PATH}"
export LD_LIBRARY_PATH="${ROSE_SH_DEPS_PREFIX}/lib:${ROSE_SH_DEPS_PREFIX}/lib64:${LD_LIBRARY_PATH}"

# TOO1 (1/30/2014): TODO: Fix Java make install-core job and then remove this:
source /nfs/casc/overture/ROSE/opt/rhel5/x86_64/java/jdk/latest/setup.sh || true

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

clone_repository()
{
  local repository_name="$1" local_clone_name="$2"
  : ${local_clone_name:="${repository_name}-src"}

  [ -z "${repository_name}" ] && fail "Usage: clone_repository <repository_name>"

  for mirror_url in ${REPOSITORY_MIRROR_URLS}; do
    local repository_url="${mirror_url}/${repository_name}.git"

    info "Attempting to git-clone: '${repository_url}'"

    git clone --progress "${repository_url}" "${local_clone_name}" >&1
    if test $? -eq 0; then
        return 0
    else
        info "Could not clone '${repository_name}' from mirror '${mirror_url}'"
        continue
    fi
  done

  fail "Unable to clone '${repository_name}'"
}

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
    #info "Sourcing dependency script '${dependency}'"
    source "${dependency}" || exit 1
done

#-------------------------------------------------------------------------------
usage()
#-------------------------------------------------------------------------------
{
  cat <<-EOF
--------------------------------------------------------------------------------
Help Information
--------------------------------------------------------------------------------

  Usage:

      $ ./rose.sh <application> [--help]

  Description

      Compiles <application> after installing any dependencies.

      A new directory "./workspace/<application>" will be created
      to be used as the application's workspace.

      Dependencies are installed to a new directory:
      "./dependencies/installation"

  Example:

      $ ROSE_CC="\$(which identityTranslator)" ./rose.sh apache_cassandra

  Environment Variables:

    ROSE_CC     The ROSE compiler used during Stage 1 of testing; must be
                absolute path to compiler. (Use for C/C++/Java.)

    CC          The C compiler used during Stage 2 of testing (default: gcc)
    JAVAC       The Java compiler used during Stage 2 of testing (default: javac)

  Applications:

    $(echo ${APPLICATIONS_LIST} | xargs)

--------------------------------------------------------------------------------
EOF
}

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
      [ ${PIPESTATUS[0]} -ne 0 ] && fail "Failed during Phase 1 of '${application}'" || true

      (

          phase_2 || exit 1

      ) 2>&1 | while read; do echo "[Phase 2] ${REPLY}"; done
      [ ${PIPESTATUS[0]} -ne 0 ] && fail "Failed during Phase 2 of '${application}'" || true

    popd
}

# Build in a separate workspace, so we don't pollute the user's current directory.
rm -rf "${application_workspace}"   || fail "main::remove_workspace failed"
mkdir -p "${application_workspace}" || fail "main::create_workspace failed"
pushd "${application_workspace}"    || fail "main::cd_into_workspace failed"

#-------------------------------------------------------------------------------
# Usage
#-------------------------------------------------------------------------------
if [ -z "$1" -o "x$1" = "xhelp" -o "x$1" = "x-h" -o "x$1" = "x-help" -o "x$1" = "x--help" ]; then
    usage
    exit 0
fi

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
if [ ${PIPESTATUS[0]} -ne 0 ]; then
  info ""
  info "-------------------------------------------------------------------------------"
  info "Failed during execution of '${application}' tests. See log output: '${application_log}'"
  info ""
  cat "${application_log}" | grep "FATAL" | sed 's/\[INFO\]/[BACKTRACE]/g'
  info ""
  fail "Terminated with failure."
  exit 1
fi

info "-------------------------------------------------------------------------------"
info "SUCCESS"
exit 0
