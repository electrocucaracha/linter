#!/bin/bash
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c)
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

set -o pipefail
set -o errexit
set -o nounset
set -o xtrace

if ! command -v docker; then
    # NOTE: Shorten link -> https://github.com/electrocucaracha/pkg-mgr_scripts
    curl -fsSL http://bit.ly/install_pkg | PKG=docker bash
fi

rm -rf ../.tox

docker run --rm -e RELENG_LINTER_TOOL="" -e DEBUG=true electrocucaracha/linter
for tool in shellcheck hadolint; do
    docker run --rm --workdir /src -e RELENG_LINTER_TOOL="$tool" \
    -v "$(pwd)/../:/src" electrocucaracha/linter
done
docker run --rm --workdir /src -e RELENG_LINTER_TOOL="kube-linter" \
-v "$(pwd)/k8s:/src" electrocucaracha/linter
