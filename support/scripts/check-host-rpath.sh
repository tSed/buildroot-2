#!/bin/bash
##
## check-host-rpath.sh
##
## Author(s):
##  - Samuel MARTIN <s.martin49@gmail.com>
##
## Copyright (C) 2012 Samuel MARTIN
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
##

BR2_ROOT_DIR="$(readlink -f $(dirname ${0})/../../)"
BR2_BUILD_DIR="${BR2_ROOT_DIR}/output/build/"

OUTPUT_LOG="${BR2_ROOT_DIR}/check-host-rpath.log"
OUTPUT_STATUS="${BR2_ROOT_DIR}/check-host-rpath.status"
OUTPUT_TERM="/dev/stdout"

_ACTIONS='check list log'
ACTION=

BR2_HOST_DIR=

do_parse_args() {
  while [ $# -gt 0 ] ; do
    case $1 in
      '--host-dir'|'-d')
        shift
        BR2_HOST_DIR="${1}"
        ;;
      '--help'|'-h')
        usage
        exit
        ;;
      *)
        ACTION="${1}"
        ;;
    esac
    shift
  done
}
: ${ACTION:=check}
: ${BR2_HOST_DIR:="${BR2_ROOT_DIR}/output/host"}

do_scan_elffile() {
  local elffile="${1}"
  if file "${elffile}" | grep -q "${elffile}: ELF.*\? statically linked," ; then
    return 1
  elif ! readelf -d "${elffile}" | grep -q "rpath" ; then
    return 2
  elif ! readelf -d "${elffile}" | grep -q "rpath: \[.*\?${BR2_BUILD_DIR}" ; then
    return 3
  else
    return 10
  fi
}

do_log_rpath() {
  local elffile="${1}" linktype="${2}"
  local mess_lg="checking ${elffile//${BR2_ROOT_DIR}\//} ..." mess_st= mess_sh=
  local _txt=
  case "${linktype}" in
    1)
      mess_lg="${mess_lg} ok (statically linked)\n"
      mess_st="${mess_lg}" mess_sh="${mess_lg}"
      ;;
    2)
      mess_lg="${mess_lg} ok (do not use rpath)\n"
      mess_st="${mess_lg}" mess_sh="${mess_lg}"
      ;;
    3)
      mess_lg="${mess_lg} ok\n"
      mess_st="${mess_lg}" mess_sh="${mess_lg}"
      _txt=$(readelf -d ${elffile} | grep rpath | \
        sed -e 's/.*\?\[\(.*\?\)\]$/\1/' -e 's/:/\n  /g' -e 's/^\(.*\)/  \1/g')
      mess_lg="${mess_lg}${_txt}\n"
      mess_st="${mess_lg}${_txt}\n"
      ;;
    10)
      mess_lg="${mess_lg} not ok\n"
      mess_lg="${mess_lg}" mess_sh="${mess_lg}"
      _txt=$(readelf -d ${elffile} | grep rpath | \
        sed -e 's/.*\?\[\(.*\?\)\]$/\1/' -e 's/:/\n  /g' -e 's/^\(.*\)/  \1/g')
      mess_lg="${mess_lg}${_txt}\n"
      mess_st="${mess_lg}${_txt}\n"
      ;;
    *)
      ;;
  esac
  printf "${mess_lg}" >> "${OUTPUT_LOG}"
  printf "${mess_st}" >> "${OUTPUT_STATUS}"
  printf "${mess_sh}" >> "${OUTPUT_TERM}"
}

post_log_rpath() {
  return 0
}

do_list_rpath() {
  do_log_rpath $@
}

post_list_rpath() {
  local _list_rpath="$(grep '^  ' ${OUTPUT_LOG} | cut -b3- | sort | uniq | sed -e 's/\n/\n  /g')\n"
  local mess_lg="\nrpath list:" mess_st= mess_sh=
  mess_lg="${mess_lg}\n${_list_rpath}\n" mess_st="${mess_lg}" mess_sh="${mess_lg}"
  printf "${mess_lg}" >> "${OUTPUT_LOG}"
  printf "${mess_st}" >> "${OUTPUT_STATUS}"
  printf "${mess_sh}" >> "${OUTPUT_TERM}"
  return 0
}

do_check_wrong_rpath() {
  local elffile="${1}" linktype="${2}"
  local mess_lg="checking ${elffile//${BR2_ROOT_DIR}\//} ..." mess_st= mess_sh=
  local _txt=
  case "${linktype}" in
    1)
      mess_lg="${mess_lg} ok (statically linked)\n"
      mess_st="${mess_lg}" mess_sh="${mess_lg}"
      ;;
    2)
      mess_lg="${mess_lg} ok (do not use rpath)\n"
      mess_st="${mess_lg}" mess_sh="${mess_lg}"
      ;;
    3)
      mess_lg="${mess_lg} ok\n"
      mess_st="${mess_lg}" mess_sh="${mess_lg}"
      ;;
    10)
      mess_lg="${mess_lg} not ok\n"
      mess_lg="${mess_lg}" mess_sh="${mess_lg}"
      _txt=$(readelf -d ${elffile} | grep rpath | \
        sed -e 's/.*\?\[\(.*\?\)\]$/\1/' -e 's/:/\n  /g' -e 's/^\(.*\)/  \1/g')
      mess_lg="${mess_lg}${_txt}\n"
      mess_st="${mess_lg}${_txt}\n"
      ;;
    *)
      ;;
  esac
  printf "${mess_lg}" >> "${OUTPUT_LOG}"
  printf "${mess_st}" >> "${OUTPUT_STATUS}"
  printf "${mess_sh}" >> "${OUTPUT_TERM}"
}

post_check_wrong_rpath() {
  local _err_rpath="$(grep -E 'not ok' ${OUTPUT_LOG} | cut -d' ' -f-2 | sort | uniq | sed -e 's/^.*\? /  /')\n"
  local mess_lg="\nwrong rpath:" mess_st= mess_sh=
  mess_lg="${mess_lg}\n${_err_rpath}\n" mess_st="${mess_lg}" mess_sh="${mess_lg}"
  printf "${mess_lg}" >> "${OUTPUT_LOG}"
  printf "${mess_st}" >> "${OUTPUT_STATUS}"
  printf "${mess_sh}" >> "${OUTPUT_TERM}"
  grep -qE 'not ok$' "${OUTPUT_LOG}"
  test $? -ne 0
}


if [ ! -d "${BR2_HOST_DIR}" ] ; then
  echo "no directory at: ${BR2_HOST_DIR}"
  exit 1
fi

rm -f "${OUTPUT_LOG}" "${OUTPUT_STATUS}"
_error=0

printf "${0##*/}: running ${ACTION}\n"         >> "${OUTPUT_LOG}"
printf "host directory : ${BR2_HOST_DIR}\n"    >> "${OUTPUT_LOG}"
printf "build directory: ${BR2_BUILD_DIR}\n\n" >> "${OUTPUT_LOG}"

for f in $(find "${BR2_HOST_DIR}" -type f -a '(' -path '*/usr/lib/*' -o -path '*/usr/bin/*' -o -path '*/usr/sbin/*' ')' -a \
  ! '(' -path '*/sysroot/*' -o -path '*/include/*' -o -path '*/share/locale/*' -o \
        -path '*/share/info/*' -o -path '*/man/*' -o -path '*/share/terminfo/*' -o \
        -path '*/usr/lib/gcc/*' -o -path '*/usr/*/lib/*' -o \
        -path '*/html/*' -o -name '*.cmake' -o -name '*.txt' -o \
        -name 'arm-unknown-linux-uclibcgnueabi*' ')' ) ; do
  file "${f}" | grep -q "${f}: ELF" || continue
  do_scan_elffile "${f}"
  result=$?
  echo "${f}"
  # echo
  # ${BR2_HOST_DIR}/usr/bin/chrpath -l "${f}" 2>/dev/null | sed -e 's/: RPATH=/\n  /' -e 's/:/\n  /g'; continue
  readelf -d "${f}" | grep rpath | \
        sed -e 's/.*\?\[\(.*\?\)\]$/\1/' -e 's/:/\n  /g' -e 's/^\(.*\)/  \1/g'
  continue
  case "${ACTION}" in
    'check')
      do_check_wrong_rpath "${f}" "${result}"
      ;;
    'list')
      do_list_rpath "${f}" "${result}"
      ;;
    'log')
      do_log_rpath "${f}" "${result}"
      ;;
    *)
      ;;
  esac
done

exit
case "${ACTION}" in
  'check')
    post_check_wrong_rpath
    exitcode=$?
    ;;
  'list')
    post_list_rpath
    exitcode=$?
    ;;
  'log')
    post_log_rpath
    exitcode=$?
    ;;
  *)
    ;;
esac
exit $exitcode


# if [ ${_error} -ne 0 ] ; then
#   printf "\nFound some rpath not pointing to ${BR2_HOST_DIR}\n"
#   printf "Check ${LOG_FILE}\n"
# fi
# exit ${_error}
