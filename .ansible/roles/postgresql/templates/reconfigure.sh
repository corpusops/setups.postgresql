#!/usr/bin/env bash
# {{ansible_managed}}
set -ex
#
# Usually we will use this script twice upon the image start
# - one to reconfigure files before systemd and the service start
# - a second time after init, use case is eg to create dbs after
#   services are up, with then different skip tags
# The trick reside to use env var to control what the script will do
#
export ANSIBLE_VARARGS=""
export ANSIBLE_FOLDER="${ANSIBLE_FOLDER-ansible}"
export ANSIBLE_PLAY="${ANSIBLE_PLAY-{{cops_postgresql_ep_playbook}}}"
export SKIP_TAGS_MODE="${SKIP_TAGS_MODE-${1:-}}"
case $SKIP_TAGS_MODE in
    post)
        export ANSIBLE_SKIP_TAGS="${ANSIBLE_SKIP_TAGS-{{cops_postgresql_ep_post_start_skip_tags}}}";;
    *)
        export ANSIBLE_SKIP_TAGS="${ANSIBLE_SKIP_TAGS-{{cops_postgresql_ep_skip_tags}}}";;
    esac
if [ -e /setup/reconfigure.yml ];then
    ANSIBLE_VARARGS="-e @/setup/reconfigure.yml"
fi
export ANSIBLE_VARARGS
if [[ -z ${NO_CONFIG-} ]];then
    cd /provision_dir
    if [[ -n "$ANSIBLE_FOLDER" ]] && [ -d "$ANSIBLE_FOLDER" ];then
        cd "$ANSIBLE_FOLDER"
    fi
    /srv/corpusops/corpusops.bootstrap/bin/cops_apply_role \
        $ANSIBLE_VARARGS \
        -vvvv "$ANSIBLE_PLAY" \
        --skip-tags=$ANSIBLE_SKIP_TAGS
fi
