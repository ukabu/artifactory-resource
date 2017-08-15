#!/bin/bash

set -e

source $(dirname $0)/helpers.sh

it_can_deploy_release_to_artifactory_with_maven2_layout() {

  artifactory_url=$ART_URL
  TMPDIR=/tmp

  local src=$(mktemp -d $TMPDIR/in-src.XXXXXX)
  local regex="pivotal-(?<version>.*).tar.gz"

  local username="${ART_USER}"
  local password="${ART_PWD}"

  local repository="/${ART_REPO}/artifactory-resource/test"
  local file=$(realpath "data/pivotal-1.0.1-rc1.tar.gz")

  local version=20161109222826

  cat <<EOF | $resource_dir/out "$src" | tee /dev/stderr
  {
    "params": {
      "file": "$file"
    },
    "source": {
      "endpoint": "$artifactory_url",
      "repository": "$repository",
      "layout": "maven2",
      "regex": "$regex",
      "username": "$username",
      "password": "$password"
    }
  }
EOF
}

it_can_deploy_release_to_artifactory_with_maven2_layout
