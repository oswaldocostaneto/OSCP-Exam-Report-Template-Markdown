#!/usr/bin/env bash
set -euo pipefail

cd /workspace

if [[ $# -eq 0 ]]; then
  exec bash
fi

case "$1" in
  init|generate)
    exec ruby osert.rb "$@"
    ;;
  *)
    exec "$@"
    ;;
esac
