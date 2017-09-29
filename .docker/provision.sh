#!/usr/bin/env bash
set -ex
log() { echo "${@}" >&2; }
vv() { log "$@"; "$@"; }
rsync $RSYNC_OPTS "$_P.in/" "$_P/" --exclude=local --delete-excluded
export ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1
lcops="$_P.in/local/corpusops.bootstrap/"

do_install() {
    cd "$_P"
    $ANSIBLE_PLAYBOOK \
        $ANSIBLE_ARGS \
        -e @/tmp/ansible_params.yml \
        $ANSIBLE_FOLDER/$ANSIBLE_PLAY
}
apt update
do_up() {
    log "Upgrading corpusops as first try failed"
    cd "$COPS_ROOT"
    bin/install.sh -C -s
}
use_local_cops() {
    set +x
    if [ -e "$lcops" ];then
        log "Local checkout of corpusops.bootstrap; using it"
        for i in \
            bin/ doc/ docker/ hacking/ LICENSE.txt \
            playbooks/ README.md requirements/ roles/ setup.py src/ \
            ;do
            rsync -a "$lcops/$i" "$COPS_ROOT/$i"
        done
    fi
    set -x
}
use_local_cops
if [[ -n ${DO_UP-} ]] && ! do_up;then
    log "do re-upgrade failed"
    exit 3
fi
if do_install;then
    log "installed"
elif [ "x${COPS_ROOT}" != x"" ];then
    if ! do_up;then
        log "do upgrade failed"
        exit 3
    fi
    if do_install;then
        log "installed (2)"
    else
        log "fail install (2)"
        exit 4
    fi
else
    log "fail install"
    exit 5

fi
if [[ -n ${DO_CONTAINER_STRIP-} ]] && \
    [ -e /sbin/cops_container_strip.sh ] && \
    ! vv /sbin/cops_container_strip.sh;then
    log "do container strip failed"
    exit 6
fi
# vim:set et sts=4 ts=4 tw=80:
