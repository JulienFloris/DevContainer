FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04@sha256:3612b800eaae8513e7dca54f21d2e4eda48eda57426f3746a78677f342ac7ee9

USER root

COPY common/versions.env /tmp/devcontainer/versions.env

RUN set -eux; \
    . /tmp/devcontainer/versions.env; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates curl git gnupg less lsb-release openssh-client tar unzip; \
    mkdir -p /etc/apt/keyrings; \
    curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg; \
    chmod go+r /etc/apt/keyrings/microsoft.gpg; \
    printf '%s\n' \
      'Types: deb' \
      'URIs: https://packages.microsoft.com/repos/azure-cli/' \
      'Suites: noble' \
      'Components: main' \
      'Architectures: amd64' \
      'Signed-by: /etc/apt/keyrings/microsoft.gpg' \
      >/etc/apt/sources.list.d/azure-cli.sources; \
    apt-get update; \
    apt-get install -y --no-install-recommends "azure-cli=${AZURE_CLI_VERSION}-1~noble"; \
    rm -rf /var/lib/apt/lists/*

COPY common/ /tmp/devcontainer/
RUN bash /tmp/devcontainer/install-common.sh && rm -rf /tmp/devcontainer

USER vscode
WORKDIR /workspaces
CMD ["sleep", "infinity"]
