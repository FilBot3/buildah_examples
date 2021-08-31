.PHONY: buildah-build podman-build buildah-multi-stage buildah-copy-artifact

buildah-build:
	bash ./src/bash/buildah_build_containerfile.sh

podman-build:
	bash ./src/bash/podman_build_containerfile.sh

buildah-multi-stage:
	buildah unshare ./src/bash/buildah_multi-stage_build.sh

buildah-copy-artifact:
	buildah unshare ./src/bash/buildah_copy_artifact_from_container.sh


