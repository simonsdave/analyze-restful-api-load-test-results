#!/usr/bin/env bash
curl -s https://raw.githubusercontent.com/simonsdave/dev-env/master/ubuntu/trusty/create_dev_env.sh | bash -s -- "$PWD/provision.sh" "$@"
exit $?
