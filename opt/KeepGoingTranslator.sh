#!/bin/bash

: ${KG__STRIP_PATH:=}
: ${KG__EXPECTATIONS_FILE:=}
: ${KG__REPORT_FAIL:=}
: ${KG__REPORT_PASS:=}
: ${KG__ROSE_FLAGS:=}

if test -n "${KG__STRIP_PATH}"; then
  KG__ROSE_FLAGS="${KG__ROSE_FLAGS} --strip-path-prefix=${KG__STRIP_PATH}"
fi
if test -n "${KG__EXPECTATIONS_FILE}"; then
  KG__ROSE_FLAGS="${KG__ROSE_FLAGS} --expectations=${KG__EXPECTATIONS_FILE}"
fi
if test -n "${KG__REPORT_FAIL}"; then
  KG__ROSE_FLAGS="${KG__ROSE_FLAGS} --report-fail=${KG__REPORT_FAIL}"
fi
if test -n "${KG__REPORT_PASS}"; then
  KG__ROSE_FLAGS="${KG__ROSE_FLAGS} --report-pass=${KG__REPORT_PASS}"
fi

KeepGoingTranslator $* ${KG__ROSE_FLAGS} || exit 1
