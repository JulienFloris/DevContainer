Describe 'PowerShell dev container' {
    It 'runs on Linux' {
        $IsLinux | Should -BeTrue
    }

    It 'provides the Azure and Graph login commands' {
        Get-Command Connect-AzAccount | Should -Not -BeNullOrEmpty
        Get-Command Connect-MgGraph | Should -Not -BeNullOrEmpty
    }
}
