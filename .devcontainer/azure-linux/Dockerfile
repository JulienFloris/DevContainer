FROM mcr.microsoft.com/azurelinux/base/core:3.0@sha256:c877612270d1ee2d6ab2bc1f64bfe38ab697ac50be325154ee5129fce89c17e4

USER root

COPY common/versions.env /tmp/devcontainer/versions.env

RUN set -eux; \
    . /tmp/devcontainer/versions.env; \
    tdnf install -y \
      bash ca-certificates curl findutils gawk git gzip icu less libunwind openssh-clients \
      openssl shadow-utils sudo tar unzip util-linux zlib; \
    tdnf install -y "azure-cli-${AZURE_CLI_VERSION}-1.azl3"; \
    tdnf clean all

COPY common/ /tmp/devcontainer/
RUN bash /tmp/devcontainer/install-common.sh && rm -rf /tmp/devcontainer

USER vscode
WORKDIR /workspaces
CMD ["sleep", "infinity"]
