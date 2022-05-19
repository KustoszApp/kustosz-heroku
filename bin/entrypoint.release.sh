#!/usr/bin/env bash
#
# https://github.com/olivergondza/bash-strict-mode
set -euo pipefail
trap 's=$?; echo >&2 "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
shopt -s nullglob

# run migrate by default
if [ -z "${KUSTOSZ_SKIP_MIGRATE:+x}" ]; then
    kustosz-manager migrate --noinput
fi

# create cache table by default
if [ -z "${KUSTOSZ_SKIP_CREATECACHETABLE:+x}" ]; then
    kustosz-manager createcachetable
fi

# import channels from opml directory
if [ -z "${KUSTOSZ_SKIP_IMPORT_CHANNELS:+x}" ]; then
    for OPMLFILE in "$KUSTOSZ_BASE_DIR"/opml/* ; do
        kustosz-manager import_channels --file "$OPMLFILE" opml
    done
fi

# set username and password by default, unless provided explicitly
if [ -z "${KUSTOSZ_SKIP_PASSWORD_GENERATION:+x}" ] && [ -z "${KUSTOSZ_USERNAME:+x}" ] && [ -z "${KUSTOSZ_PASSWORD:+x}" ]; then
    export KUSTOSZ_USERNAME="admin"
    export KUSTOSZ_PASSWORD="$(openssl rand -base64 30)"
    export KUSTOSZ_PASSWORD_GENERATED=1
fi

# maybe create user, if variables are provided / generated
if [ ! -z "${KUSTOSZ_USERNAME:+x}" ] && [ ! -z "${KUSTOSZ_PASSWORD:+x}" ]; then
    if ! (
        echo "from django.contrib.auth import get_user_model"
        echo "get_user_model().objects.get(username='${KUSTOSZ_USERNAME}')"
    ) | kustosz-manager shell >/dev/null 2>&1 ; then
        kustosz-manager createsuperuser --no-input --username "$KUSTOSZ_USERNAME" --email user${RANDOM}@example.invalid
        (
            echo "from django.contrib.auth import get_user_model"
            echo "user = get_user_model().objects.get(username='${KUSTOSZ_USERNAME}')"
            echo "user.set_password('${KUSTOSZ_PASSWORD}')"
            echo "user.save(update_fields=('password',))"
        ) | kustosz-manager shell

        if [ ! -z "${KUSTOSZ_PASSWORD_GENERATED:+x}" ]; then
            echo "Generated random login credentials"
            echo "Username: ${KUSTOSZ_USERNAME}"
            echo "Password: ${KUSTOSZ_PASSWORD}"
            echo ""
        fi
    fi
fi
