#!/usr/bin/env bash
# This is meant to be executed from the root of the repository. Then the file
# paths will match up.

buildah bud \
  -t testimage2:latest \
  -f src/containerfiles/go-multi-build.containerfile \
  .

