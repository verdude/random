#!/usr/bin/env bash

set -Eeuo pipefail

declare -i getdiff=0 reverse=0 untar=0 force=0
DOTDIR=${DOTDIR:-}
name="p"
efile="p.enc"
dfile="${name}.tar.gz"
pfile="${HOME}/.secretpw"
decrypt=""
force=""
cipher="chacha20"
tarargs=(--mtime=0)
keyderivation="pbkdf2"
rmflags="-f"
tarcomp="z"
tempcheckdir=""
private=(
  .secrets.sh
  .bin/
)

if [[ "$OSTYPE" =~ darwin* ]]; then
  tarargs=()
fi

function usage() {
  cat <<EOF
Options:
  -f            Force
  -d            Decrypt
  -p <filepath> Set pfile
  -y            Prompt for each deletion
  -t            untar after extraction
  -c            Get diff
  -r            Reverse diff inputs
  -x            set -o xtrace
EOF
}

while getopts :fdD:p:hoxytcr flag; do
  case ${flag} in
    f) force=1 ;;
    d) decrypt="-d" ;;
    p) pfile="${OPTARG}" ;;
    y) rmflags="-i" ;;
    t) untar=1 ;;
    c) getdiff=1 ;;
    r) reverse=1 ;;
    D) DOTDIR="${OPTARG}" ;;
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
    tar -c${tarcomp}f "${dfile}" "${tarargs[@]}" "${private[@]}"
  elif [[ ! -f "${efile}" ]]; then
    echo "enc: ${efile} not found. cannot decrypt." >&2
    exit 1
  fi

  opensslargs=("enc" ${dec:+"${dec}"} "-pass" "file:${pfile}" "-${cipher}"
    "-in" "${infile}" "-out" "${outfile}" "-${keyderivation}")

  openssl ${opensslargs[@]}

  if (( untar )); then
    tar x${tarcomp}f "${dfile}" "${tarargs[@]}"
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

  tar "${tarargs[@]}" -c${tarcomp}f "${newf}" "${private[@]}"
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
    args=("${tempcheckdir}/${file}" "${file}")
    if (( reverse )); then
      args=("${file}" "${tempcheckdir}/${file}")
    fi
    git diff --no-index "${args[@]}"
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

if (( force )); then
  enc ${decrypt}
  echo Forced.
elif check; then
  enc ${decrypt}
  echo Updated.
else
  echo No change.
fi
