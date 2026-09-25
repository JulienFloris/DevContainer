[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $VersionsFile
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$versions = @{}
foreach ($line in Get-Content -LiteralPath $VersionsFile) {
    if ($line -match '^(?<Name>[A-Z0-9_]+)=(?<Value>.+)$') {
        $versions[$Matches.Name] = $Matches.Value.Trim()
    }
}

$modules = [ordered]@{
    'Az'              = $versions.AZ_VERSION
    'Microsoft.Graph' = $versions.MICROSOFT_GRAPH_VERSION
    'Pester'          = $versions.PESTER_VERSION
    'PSScriptAnalyzer'= $versions.PSSCRIPTANALYZER_VERSION
    'PSReadLine'      = $versions.PSREADLINE_VERSION
}

foreach ($module in $modules.GetEnumerator()) {
    Write-Information "Installing $($module.Key) $($module.Value)" -InformationAction Continue
    Install-PSResource `
        -Name $module.Key `
        -Version $module.Value `
        -Repository PSGallery `
        -Scope AllUsers `
        -TrustRepository `
        -AcceptLicense `
        -Reinstall
}
