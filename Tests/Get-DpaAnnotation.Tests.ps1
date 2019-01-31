$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot\Shared.ps1

Describe "$CommandName Unit Tests" -Tag 'Unit' {
    Context "Command Design" {
        $command = Get-Command -Name $CommandName

        $testCases = @(
            @{ Name = 'DatabaseId'; Mandatory = $true },
            @{ Name = 'StartTime'; Mandatory = $false },
            @{ Name = 'EndTime'; Mandatory = $false }
        )
        It 'should have a <Name> parameter' -TestCases $testCases {
            param ( $Name , $Mandatory = $true )
            $command | Should -HaveParameter $Name -Mandatory:$Mandatory
        }

        It 'should default StartTime to 30 days ago' {

        }

        It 'should default EndTime to now' {

        }
    }
}

Describe "$CommandName Integration Tests" -Tag 'Integration' {

}