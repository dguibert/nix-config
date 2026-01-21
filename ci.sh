#!/usr/bin/env bash
set -euo pipefail

args=(
  --accept-flake-config
  --gc-roots-dir gc-root
  --max-memory-size "12000"
  --option allow-import-from-derivation true
  --show-trace
  --check-cache-status
  --workers 4
  "${@:---force-recurse}"
  "${@:-./ci.nix}"
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
    local job=$1
    job=$(echo "$job" | base64 -d)
    attr=$(echo "$job" | jq -r .attr)
    cacheStatus=$(echo "$job" | jq -r .cacheStatus)
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
        if [[ "$cacheStatus" == "local" ]]; then
            log "** ☑️  $attr ($drvPath)"
        elif [[ "$cacheStatus" == "cached" ]]; then
            log "** ☑️  $attr cached ($drvPath)"
        else
            mkdir -p results
            rm -rf results/$attr results/log-$attr.log
            if ! nix build --out-link results/$attr -L $drvPath^* 2>&1 | tee results/log-$attr.log; then
                log "** ❌ $attr ($drvPath)"
                log
                log "*** Build error: last 50 lines"
                log "$(tail -n 50 results/log-$attr.log)"
                error=1
            else
                log "** ✅ $attr ($drvPath)"
            fi
        fi
        log
    fi
}
export -f process_jsonline log

log "* Testing on $(git describe --always --tags)"
# --flake .#checks.x86_64-linux
rm -rf gc-root results
#nix-eval-jobs "${args[@]}" > jobs.json
test -f ~/.parallel/will-cite || (mkdir ~/.parallel; touch ~/.parallel/will-cite)
#cat jobs.json | jq -r '. | @base64' > jobs.base64
#parallel process_jsonline {} :::: jobs.base64
cat jobs.base64 | xargs --verbose -P $(nproc) -I{} bash -c 'process_jsonline "{}"'

# TODO: improve the reporting
# exit "$error"
