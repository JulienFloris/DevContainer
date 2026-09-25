#!/usr/bin/env bash
set -euo pipefail

source /tmp/devcontainer/versions.env

install_powershell() {
    local archive="/tmp/powershell.tar.gz"
    curl --fail --location --retry 5 \
        "https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell-${POWERSHELL_VERSION}-linux-x64.tar.gz" \
        --output "${archive}"
    echo "${POWERSHELL_SHA256}  ${archive}" | sha256sum --check --strict
    mkdir -p /opt/microsoft/powershell/7
    tar --extract --gzip --file "${archive}" --directory /opt/microsoft/powershell/7
    chmod 0755 /opt/microsoft/powershell/7/pwsh
    ln -sfn /opt/microsoft/powershell/7/pwsh /usr/local/bin/pwsh
    rm -f "${archive}"
}

install_bicep() {
    local package="/tmp/bicep.nupkg"
    local extract_dir="/tmp/bicep"
    curl --fail --location --retry 5 \
        "https://github.com/Azure/bicep/releases/download/v${BICEP_VERSION}/Azure.Bicep.CommandLine.linux-x64.${BICEP_VERSION}.nupkg" \
        --output "${package}"
    echo "${BICEP_SHA256}  ${package}" | sha256sum --check --strict
    mkdir -p "${extract_dir}"
    unzip -q "${package}" -d "${extract_dir}"
    install -m 0755 "${extract_dir}/tools/bicep" /usr/local/bin/bicep
    rm -rf "${package}" "${extract_dir}"
}

ensure_developer_user() {
    if ! getent group vscode >/dev/null; then
        groupadd --gid 1000 vscode
    fi
    if ! id vscode >/dev/null 2>&1; then
        useradd --uid 1000 --gid vscode --create-home --shell /bin/bash vscode
    fi
    mkdir -p /etc/sudoers.d
    printf 'vscode ALL=(root) NOPASSWD:ALL\n' >/etc/sudoers.d/vscode
    chmod 0440 /etc/sudoers.d/vscode
    mkdir -p /workspaces /home/vscode/.config/powershell
    chown -R vscode:vscode /workspaces /home/vscode
}

install_powershell
install_bicep
ensure_developer_user
mkdir -p /root/.local/share/PSResourceGet
pwsh -NoLogo -NoProfile -File /tmp/devcontainer/Install-Modules.ps1 \
    -VersionsFile /tmp/devcontainer/versions.env

install -d -m 0755 /usr/local/share/devcontainer
install -m 0644 /tmp/devcontainer/versions.env /usr/local/share/devcontainer/versions.env
install -m 0644 /tmp/devcontainer/Validate-Environment.ps1 /usr/local/share/devcontainer/Validate-Environment.ps1
install -m 0644 /tmp/devcontainer/test.bicep /usr/local/share/devcontainer/test.bicep
install -m 0644 /tmp/devcontainer/Smoke.Tests.ps1 /usr/local/share/devcontainer/Smoke.Tests.ps1

pwsh -NoLogo -NoProfile -File /usr/local/share/devcontainer/Validate-Environment.ps1
