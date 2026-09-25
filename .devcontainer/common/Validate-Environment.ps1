[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path -Parent $PSCommandPath
$versions = @{}
foreach ($line in Get-Content -LiteralPath (Join-Path $root 'versions.env')) {
    if ($line -match '^(?<Name>[A-Z0-9_]+)=(?<Value>.+)$') {
        $versions[$Matches.Name] = $Matches.Value.Trim()
    }
}

function Assert-Version {
    param(
        [Parameter(Mandatory)][string] $Name,
        [Parameter(Mandatory)][string] $Expected
    )

    $actual = (Get-Module -ListAvailable -Name $Name |
            Sort-Object Version -Descending |
            Select-Object -First 1).Version.ToString()
    if ($actual -ne $Expected) {
        throw "$Name version mismatch. Expected $Expected, found $actual."
    }
}

if ($PSVersionTable.PSVersion.ToString() -ne $versions.POWERSHELL_VERSION) {
    throw "PowerShell version mismatch. Expected $($versions.POWERSHELL_VERSION), found $($PSVersionTable.PSVersion)."
}

$pwshCommand = Get-Command pwsh -CommandType Application -ErrorAction Stop
if ($pwshCommand.Source -ne '/usr/local/bin/pwsh') {
    throw "PowerShell executable mismatch. Expected /usr/local/bin/pwsh, found $($pwshCommand.Source)."
}

Get-Command git -CommandType Application -ErrorAction Stop | Out-Null
Get-Command ssh -CommandType Application -ErrorAction Stop | Out-Null
git --version

$azVersion = (az version --output json | ConvertFrom-Json).'azure-cli'
if ($azVersion -ne $versions.AZURE_CLI_VERSION) {
    throw "Azure CLI version mismatch. Expected $($versions.AZURE_CLI_VERSION), found $azVersion."
}

$bicepOutput = bicep --version
if ($bicepOutput -notmatch [regex]::Escape($versions.BICEP_VERSION)) {
    throw "Bicep version mismatch. Expected $($versions.BICEP_VERSION), output was: $bicepOutput"
}

Assert-Version -Name Az -Expected $versions.AZ_VERSION
Assert-Version -Name Microsoft.Graph -Expected $versions.MICROSOFT_GRAPH_VERSION
Assert-Version -Name Pester -Expected $versions.PESTER_VERSION
Assert-Version -Name PSScriptAnalyzer -Expected $versions.PSSCRIPTANALYZER_VERSION
Assert-Version -Name PSReadLine -Expected $versions.PSREADLINE_VERSION

Import-Module Az -RequiredVersion $versions.AZ_VERSION -Force
Import-Module Microsoft.Graph.Authentication -RequiredVersion $versions.MICROSOFT_GRAPH_VERSION -Force
Get-Command Connect-AzAccount -ErrorAction Stop | Out-Null
Get-Command Connect-MgGraph -ErrorAction Stop | Out-Null

$analysis = Invoke-ScriptAnalyzer -Path $PSCommandPath -Severity Error
if ($analysis) {
    $analysis | Format-Table -AutoSize | Out-String | Write-Error
}

$pesterResult = Invoke-Pester -Path (Join-Path $root 'Smoke.Tests.ps1') -PassThru
if ($pesterResult.FailedCount -gt 0) {
    throw 'The Pester smoke test failed.'
}

$bicepOutputPath = Join-Path ([System.IO.Path]::GetTempPath()) 'devcontainer-test.json'
bicep build (Join-Path $root 'test.bicep') --outfile $bicepOutputPath
Remove-Item -LiteralPath $bicepOutputPath -Force

Write-Information 'Dev container validation completed successfully.' -InformationAction Continue
