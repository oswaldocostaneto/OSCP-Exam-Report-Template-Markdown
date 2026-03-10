#!/usr/bin/env bash
set -euo pipefail

OSERT_HOME="${OSERT_HOME:-/opt/osert}"
OSERT_DATA_DIR="${OSERT_DATA_DIR:-/data}"
mkdir -p "${OSERT_DATA_DIR}"
cd "${OSERT_HOME}"

normalize_user_path() {
  local p="$1"
  local fallback_base="${2:-$OSERT_DATA_DIR}"
  if [[ "$p" = /* ]]; then
    printf '%s\n' "$p"
  else
    for base in "$OSERT_DATA_DIR" /workspace "$OSERT_HOME"; do
      if [[ -e "${base}/${p}" ]]; then
        printf '%s/%s\n' "$base" "$p"
        return
      fi
    done

    printf '%s/%s\n' "$fallback_base" "$p"
  fi
}

normalize_resource_path() {
  local p="$1"
  # Keep colon-delimited lists untouched (e.g. "/a:/b" or "a:b").
  if [[ "$p" == *:* ]]; then
    printf '%s\n' "$p"
  else
    normalize_user_path "$p"
  fi
}

if [[ $# -eq 0 ]]; then
  exec bash
fi

case "$1" in
  init|generate)
    args=("$@")
    i=0
    while [[ $i -lt ${#args[@]} ]]; do
      case "${args[$i]}" in
        -i|--input)
          j=$((i + 1))
          if [[ $j -lt ${#args[@]} ]]; then
            args[$j]="$(normalize_user_path "${args[$j]}")"
          fi
          i=$((i + 2))
          continue
          ;;
        -o|--output)
          j=$((i + 1))
          if [[ $j -lt ${#args[@]} ]]; then
            args[$j]="$(normalize_user_path "${args[$j]}" "$OSERT_DATA_DIR")"
          fi
          i=$((i + 2))
          continue
          ;;
        -r|--resource-path)
          j=$((i + 1))
          if [[ $j -lt ${#args[@]} ]]; then
            args[$j]="$(normalize_resource_path "${args[$j]}")"
          fi
          i=$((i + 2))
          continue
          ;;
        --input=*)
          key="${args[$i]%%=*}"
          val="${args[$i]#*=}"
          args[$i]="${key}=$(normalize_user_path "$val")"
          ;;
        --output=*)
          key="${args[$i]%%=*}"
          val="${args[$i]#*=}"
          args[$i]="${key}=$(normalize_user_path "$val" "$OSERT_DATA_DIR")"
          ;;
        --resource-path=*)
          key="${args[$i]%%=*}"
          val="${args[$i]#*=}"
          args[$i]="${key}=$(normalize_resource_path "$val")"
          ;;
      esac
      i=$((i + 1))
    done
    exec ruby "${OSERT_HOME}/osert.rb" "${args[@]}"
    ;;
  *)
    exec "$@"
    ;;
esac
