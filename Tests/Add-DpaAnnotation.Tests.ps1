$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot\Shared.ps1

Describe "$CommandName Unit Tests" -Tag 'Unit' {
    Context "Command Design" {
        $command = Get-Command -Name $CommandName

        $testCases = @(
            @{ Name = 'DatabaseId'; Mandatory = $true },
            @{ Name = 'Time'; Mandatory = $false },
            @{ Name = 'Description'; Mandatory = $true },
            @{ Name = 'CreatedBy'; Mandatory = $false }
        )
        It 'should have a <Name> parameter' -TestCases $testCases {
            param ( $Name , $Mandatory = $true )
            $command | Should -HaveParameter $Name -Mandatory:$Mandatory
        }

        It 'should default Time to the current time' {

        }

        It 'should default CreatedBy to the current user' {

        }
    }
}

Describe "$CommandName Integration Tests" -Tag 'Integration' {

}