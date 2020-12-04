#!/usr/bin/env zsh

container_from=${1:-"registry.fedoraproject.org/f33/fedora-toolbox:33"}

set -e

local BOLD=$(tput bold)
local GREEN=$(tput setaf 2)
local WHITE=$(tput setaf 7)
local RESET=$(tput sgr0)

function step() {
    # Print a message to stdout with fancy coloring. Usable in ZSH
    #
    # Parameters
    # ----------
    # $1 : string - Message to display to stdout
    echo
    echo "${BOLD}${GREEN}>>> ${WHITE}$1...${RESET}"
}

step "Pull the container: ${container_from}"
container_base=$(buildah from "${container_from}")

step "Perform a full upgrade"
buildah run "${container_base}" -- dnf update -y --refresh

step "Install Development Tools"
buildah run "${container_base}" -- dnf groupinstall -y "Development Tools"

step "Install packages for vim anc coc.nvim"
buildah run "${container_base}" -- dnf install -y \
    nodejs \
    yarnpkg \
    ruby \
    python3 \
    python3-devel \
    vim

step "Add the Kubernetes repo."
#buildah add --chown root:root "${container_base}" kubernetes_kubectl.repo /etc/yum.repos.d/kubernetes.repo
buildah run "${container_base}" -- sh -c "cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF"

step "Install kubectl"
buildah run "${container_base}" -- dnf install -y kubectl

step "Configure the Terraform repo"
buildah run "${container_base}" -- dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo

step "Install Terraform"
buildah run "${container_base}" -- dnf install -y terraform

step "Install Helm"
buildah run "${container_base}" -- sh -c "curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash"

step "Create non-root user"
buildah run "${container_base}" -- useradd -g wheel filbot

step "Setting default user"
buildah config --user "filbot" "${container_base}"

step "Setting the working directory"
buildah config --workingdir "/home/filbot" "${container_base}"

step "Setting the entrypoint"
buildah config --entrypoint '["/bin/bash"]' "${container_base}"

step "Setting the runtime command"
buildah config --cmd '["--login"]' "${container_base}"

step "Committing the container to Podman"
buildah commit --rm "${container_base}" filbox