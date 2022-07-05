#!/usr/bin/env bash
# Copyright 2022 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euox pipefail

# just in case we're not using docker 20.10
export DOCKER_CLI_EXPERIMENTAL=enabled

REGISTRY=gcr.io/k8s-staging-tg-exporter
IMAGE=$REGISTRY/testgrid-json-exporter
TAG=${TAG:-$(git describe --tags --always --dirty)}

ARCHES=(amd64)
VERSION=v$(cat VERSION)
TAGS=("$TAG" "$VERSION" latest)

for ARCH in "${ARCHES[@]}"; do
    docker build \
        --platform "linux/$ARCH" \
        -t "$IMAGE-$ARCH:$TAG" \
        -t "$IMAGE-$ARCH:$VERSION" \
        -t "$IMAGE-$ARCH:latest" \
        --build-arg version="$VERSION" \
        -f Containerfile \
        .
    for T in "${TAGS[@]}"; do
        docker push "$IMAGE-$ARCH:$T"
    done
done

for T in "${TAGS[@]}"; do
    docker manifest create --amend "$IMAGE:$T" \
        "$IMAGE-amd64:$T"

    for ARCH in "${ARCHES[@]}"; do
        docker manifest annotate --arch "$ARCH" "$IMAGE:$T" "$IMAGE-$ARCH:$T"
    done

    docker manifest push --purge "$IMAGE:$T"
done
