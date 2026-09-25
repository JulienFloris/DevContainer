FROM registry.access.redhat.com/ubi9/ubi@sha256:abdef1603c7dd3281d9223b0419e3cc59446e4a8137f2a7ed5cc5bd7da981f8b

USER root

COPY common/versions.env /tmp/devcontainer/versions.env

RUN set -eux; \
    . /tmp/devcontainer/versions.env; \
    dnf install -y \
      bash ca-certificates curl findutils gawk git gzip less libicu openssh-clients \
      openssl shadow-utils sudo tar unzip util-linux zlib; \
    rpm --import https://packages.microsoft.com/keys/microsoft.asc; \
    curl --fail --location --retry 5 \
      https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm \
      --output /tmp/packages-microsoft-prod.rpm; \
    rpm -Uvh /tmp/packages-microsoft-prod.rpm; \
    rm -f /tmp/packages-microsoft-prod.rpm; \
    dnf install -y "azure-cli-${AZURE_CLI_VERSION}-1.el9"; \
    dnf clean all; \
    rm -rf /var/cache/dnf

COPY common/ /tmp/devcontainer/
RUN bash /tmp/devcontainer/install-common.sh && rm -rf /tmp/devcontainer

USER vscode
WORKDIR /workspaces
CMD ["sleep", "infinity"]
