#!/usr/bin/env bash
OW=$(pwd)
W=$(cd "$(dirname $0)/.." && pwd)
COPS_ROOT="$W/local/corpusops.bootstrap"
if [[ -z ${SKIP_COPS-} ]] && [ ! -e "$COPS_ROOT" ];then
    git clone https://github.com/corpusops/corpusops.bootstrap "$COPS_ROOT"
fi
"$COPS_ROOT/hacking/docker_build_chain.py" $@
# vim:set et sts=4 ts=4 tw=80:
