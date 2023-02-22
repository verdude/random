#!/usr/bin/env bash

set -Eeuo pipefail

declare -i getdiff=0
DOTDIR=${DOTDIR:-}
name="p"
efile="p.enc"
dfile="${name}.tar.gz"
pfile="${HOME}/.secretpw"
decrypt=""
force=""
cipher="chacha20"
keyderivation="pbkdf2"
rmflags="-f"
untar=""
tarcomp="z"
tempcheckdir=""
private=(
  .secrets.sh
  .texterrc
  .bin/
)

function usage() {
  cat <<EOF
Options:
  -f            Force
  -d            Decrypt
  -p <filepath> Set pfile
  -y            Prompt for each deletion
  -t            untar after extraction
  -c            Get diff
  -x            set -o xtrace
EOF
}

while getopts :fdp:hoxytc flag; do
  case ${flag} in
    f) force="yeah" ;;
    d) decrypt="-d" ;;
    p) pfile="${OPTARG}" ;;
    y) rmflags="-i" ;;
    t) untar="yeah" ;;
    c) getdiff=1 ;;
    x) set -x ;;
    h)
      usage
      exit 0
      ;;
    :)
      echo "-${OPTARG}: Requires an argument." >&2
      usage
      exit 1
      ;;
    ?)
      echo "-${OPTARG}: Invalid argument." >&2
      usage
      exit 1
      ;;
  esac
done

# remove temp files
function _cleanup() {
  rm ${rmflags} -- *.tar.gz
  rm -rf "${tempcheckdir}"
}
trap _cleanup EXIT

# decrypt or encrypt private files depending on
# whether -d was passed in or not.
function enc() {
  if [[ ! -f "${pfile}" ]]; then
    echo "enc: ${pfile} not found." >&2
    exit 1
  fi

  local dec=${1:-}
  local infile="${efile}"
  local outfile="${dfile}"

  if [[ ${dec} != "-d" ]]; then
    dec=""
    infile="${dfile}"
    outfile="${efile}"
    tar --mtime=0 -c${tarcomp}f "${dfile}" "${private[@]}"
  elif [[ ! -f "${efile}" ]]; then
    echo "enc: ${efile} not found. cannot decrypt." >&2
    exit 1
  fi

  opensslargs=("enc" ${dec:+"${dec}"} "-pass" "file:${pfile}" "-${cipher}"
    "-in" "${infile}" "-out" "${outfile}" "-${keyderivation}")

  openssl ${opensslargs[@]}

  if [[ -n "${untar}" ]]; then
    tar x${tarcomp}f "${dfile}"
  fi
}

# check if private files have been changed.
# Returns 0 if files have changed.
function check() {
  local oldhash
  local newhash
  local newf

  enc -d

  oldhash=$(shasum "${dfile}" | cut -d' ' -f1)
  newhash=${oldhash}
  newf="$(openssl rand -hex 5).temp.tar.gz"

  tar --mtime=0 -c${tarcomp}f "${newf}" "${private[@]}"
  newhash=$(shasum "${newf}" | cut -d' ' -f1)

  if [[ "${oldhash}" != "${newhash}" ]]; then
    return 0
  else
    return 1
  fi
}

function getdiff() {
  tempcheckdir=$(mktemp -d)
  enc -d
  tar kxf "${dfile}" -C "${tempcheckdir}"
  for file in "${private[@]}"; do
    git diff --no-index "${tempcheckdir}/${file}" "${file}"
  done
}

if [[ -z "${DOTDIR}" ]] || [[ ! -d "${DOTDIR}" ]]; then
  echo Weird. >&2
  exit 1
fi

cd "${DOTDIR}"

if (( getdiff )); then
  getdiff
  exit 0
fi

if [[ -z "${force}" ]]; then
  if check; then
    enc ${decrypt}
    echo Updated.
  else
    echo No change.
  fi
else
  enc ${decrypt}
  echo Forced.
fi
