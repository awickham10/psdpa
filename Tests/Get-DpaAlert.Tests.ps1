$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot\Shared.ps1

Describe "$CommandName Unit Tests" -Tag 'Unit' {
    Context "Command Design" {
        $command = Get-Command -Name $CommandName

        $testCases = @(
            @{ Name = 'AlertId'; Mandatory = $false },
            @{ Name = 'AlertName'; Mandatory = $false }
        )
        It 'should have a <Name> parameter' -TestCases $testCases {
            param ( $Name , $Mandatory = $true )
            $command | Should -HaveParameter $Name -Mandatory:$Mandatory
        }
    }
}

Describe "$CommandName Integration Tests" -Tag 'Integration' {
    InModuleScope 'PSDPA' {
        It 'gets all alerts' {
            $alerts = Get-DpaAlert
            $alerts | Should -HaveCount 2
        }

        It 'gets alerts by -AlertId' {
            $alertId = 1
            $alert = Get-DpaAlert -AlertId $alertId
            $alert | Should -HaveCount 1
            $alert.AlertId | Should -BeExactly $alertId
        }

        It 'gets multiple alerts by -AlertId' {
            $alertId = @(1, 2)
            $alert = Get-DpaAlert -AlertId $alertId
            $alert | Should -HaveCount $alertId.Count
            $alertId | Foreach-Object { $alert.AlertId | Should -Contain $_ }
        }

        It 'gets alerts by -AlertName' {
            $alertName = 'Database Instance Availability'
            $alert = Get-DpaAlert -AlertName $alertName
            $alert | Should -HaveCount 1
            $alert.Name | Should -Be $alertName
        }

        It 'gets multiple alerts by -AlertName' {
            $alertNames = @('Database Instance Availability', 'Total Blocking Wait Time')
            $alerts = Get-DpaAlert -AlertName $alertNames
            $alerts | Should -HaveCount $alertNames.Count
            $alertNames | Foreach-Object { $alerts.Name | Should -Contain $_ }
        }

        It 'errors with an invalid -AlertId' {
            { Get-DpaAlert -AlertId 99 -EnableException } | Should -Throw 'The remote server returned an error: (404) Not Found.'
        }
    }
}