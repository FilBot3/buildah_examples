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

cp ${container_base_mount}/go/src/github.com/alexellis/href-counter/app ./
