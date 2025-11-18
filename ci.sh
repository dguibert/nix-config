#!/usr/bin/env bash
set -euo pipefail

args=(
  --accept-flake-config
  --gc-roots-dir gc-root
  --max-memory-size "12000"
  --option allow-import-from-derivation true
  --show-trace
  --workers 4
  "$@"
)

if [[ -n "${GITHUB_STEP_SUMMARY-}" ]]; then
  log() {
    echo "$*" >> "$GITHUB_STEP_SUMMARY"
  }
else
  log() {
    echo "$*"
  }
fi

error=0

process_jsonline() {
    set -euo pipefail
    set -x
    local job=$1
    job=$(echo "$job" | base64 -d)
    attr=$(echo "$job" | jq -r .attr)
    echo "### $attr"
    error=$(echo "$job" | jq -r .error)
    if [[ $error != null ]]; then
        log "** ❌ $attr"
        log
        log "*** Eval error"
        log "$error"
        error=1
    else
        drvPath=$(echo "$job" | jq -r .drvPath)
        test -d results && mkdir -p results
        if ! nix build --out-link results/$attr -L $drvPath^* 2>&1 | tee results/log-$attr.log; then
            log "** ❌ $attr ($drvPath)"
            log
            log "*** Build error: last 50 lines"
            log "$(tail -n 50 results/log-$attr.log)"
            error=1
        else
            log "** ✅ $attr ($drvPath)"
        fi
        log
    fi
}
export -f process_jsonline log

log "* Testing .#checks.x86_64-linux on $(git describe --always --tags)"
nix-eval-jobs "${args[@]}" --flake .#checks.x86_64-linux > jobs.json
cat jobs.json | jq -r '. | @base64' | parallel process_jsonline {}

log "* Testing .#nixosConfigurations on $(git describe --always --tags)"
nix-eval-jobs "${args[@]}" --flake .#nixosConfigurations > jobs.json
cat jobs.json | jq -r '. | @base64' | parallel process_jsonline {}

# TODO: improve the reporting
# exit "$error"
