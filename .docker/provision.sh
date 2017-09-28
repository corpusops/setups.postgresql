#!/usr/bin/env bash
set -ex
rsync $RSYNC_OPTS "$_P.in/" "$_P/" --exclude=local --delete-excluded
export ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1
log() { echo "${@}" >&2; }
vv() { log "$@"; "$@"; }
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
