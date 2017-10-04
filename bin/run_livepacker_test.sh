#!/usr/bin/env bash
#
# Wrappper to launch a container in test mode to debug packer builds
# eg: ./bin/run_livepacker_test.sh .docker/packer/foobar.json
#
OW=$(pwd)
W=$(cd "$(dirname $0)/.." && pwd)
COPS_ROOT="$W/local/corpusops.bootstrap"
if [[ -z ${SKIP_COPS-} ]] && [ ! -e "$COPS_ROOT" ];then
    git clone https://github.com/corpusops/corpusops.bootstrap "$COPS_ROOT"
fi
"$COPS_ROOT/hacking/docker_livepacker_test.sh" $@
# vim:set et sts=4 ts=4 tw=80:
