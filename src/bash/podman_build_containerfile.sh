#!/usr/bin/env bash
# This is meant to be executed from the root of the repository. Then the file
# paths will match up.

podman build \
  -t testimage:latest \
  -f src/containerfiles/go-multi-build.containerfile \
  .
