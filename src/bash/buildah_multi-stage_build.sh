#!/usr/bin/env bash

function step() {
    # Print a message to stdout with fancy coloring. Usable in ZSH
    #
    # Parameters
    # ----------
    # $1 : string - Message to display to stdout
    local BOLD=$(tput bold)
    local GREEN=$(tput setaf 2)
    local WHITE=$(tput setaf 7)
    local RESET=$(tput sgr0)
    echo
    echo "${BOLD}${GREEN}>>> ${WHITE}$1...${RESET}"
}

set -x
set -e

#step "set unshare"
#buildah unshare

step "Set where we pull our container"
container_from=${1:-docker.io/library/golang:1.16}

step "Pull the image and copy the name"
container_base=$(buildah from ${container_from})
container_base_mount=$(buildah mount ${container_base})

step "Set the working directory"
buildah config --workingdir "/go/src/github.com/alexellis/href-counter/" "${container_base}"

step "go get some libraries"
buildah run "${container_base}" -- go get -d -v golang.org/x/net/html

step "Copy some sources over"
buildah copy "${container_base}" src/golang/app.go ./
buildah copy "${container_base}" src/golang/go.mod ./

step "Build our image"
buildah run "${container_base}" -- /bin/sh -c "CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app ."

# Multi-Stage Build Part
step "Get production container"
prod_container_run=$(buildah from docker.io/library/alpine:latest)
step "mount the container"
prod_container_mount=$(buildah mount ${container_base})

step "install ca-certificates"
buildah run "${prod_container_run}" -- apk --no-cache add ca-certificates

step "set working directory"
buildah config --workingdir "/root/" "${prod_container_run}"

step "copy the previous artifact to our prod container"
buildah copy "${prod_container_run}" ${container_base_mount}/go/src/github.com/alexellis/href-counter//app .

step "Set the container command"
buildah config --cmd ./app "${prod_container_run}"

# These unmount steps don't seem to work and the issues from 2019 don't seem to
# be current anymore. Something is wonky.
#step "unmount the builder"
#buildah unmount ${container_base_mount}
#step "unmount the prod mount"
#buildah unmount ${prod_container_mount}

step "Commit the container"
buildah commit --rm "${prod_container_run}" multi-stage:latest

