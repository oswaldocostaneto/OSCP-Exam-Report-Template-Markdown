#!/usr/bin/env bash
set -euo pipefail

cd /workspace

normalize_workspace_path() {
  local p="$1"
  if [[ "$p" = /* ]]; then
    printf '%s\n' "$p"
  else
    printf '/workspace/%s\n' "$p"
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
        -i|--input|-o|--output|-r|--resource-path)
          j=$((i + 1))
          if [[ $j -lt ${#args[@]} ]]; then
            args[$j]="$(normalize_workspace_path "${args[$j]}")"
          fi
          i=$((i + 2))
          continue
          ;;
        --input=*|--output=*|--resource-path=*)
          key="${args[$i]%%=*}"
          val="${args[$i]#*=}"
          args[$i]="${key}=$(normalize_workspace_path "$val")"
          ;;
      esac
      i=$((i + 1))
    done
    exec ruby osert.rb "${args[@]}"
    ;;
  *)
    exec "$@"
    ;;
esac
