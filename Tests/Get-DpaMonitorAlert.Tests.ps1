$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot\Shared.ps1

Describe "$CommandName Unit Tests" -Tag 'Unit' {
    Context "Command Design" {
        $command = Get-Command -Name $CommandName

        $testCases = @(
            @{Name = 'DatabaseId'},
            @{Name = 'MonitorName'},
            @{Name = 'Monitor'},
            @{Name = 'AlertId'},
            @{Name = 'IncludeAlertGroupAlerts'}
        )
        It 'should have a <Name> parameter' -TestCases $testCases {
            param ( $Name )
            $command | Should -HaveParameter $Name
        }
    }
}

Describe "$CommandName Integration Tests" -Tag 'Integration' {
    InModuleScope 'PSDPA' {
        Context 'returns alert data' {
            It 'should return a single alert' {
                $databaseId = 1
                $alertId = 1
                $alert = Get-DpaMonitorAlert -DatabaseId $databaseId -AlertId $alertId
                $alert | Should -HaveCount 1
                $alert.AlertId | Should -BeExactly $alertId
            }

            It 'should return multiple alerts' {
                $databaseId = 1
                $alertId = @(1, 2)
                $alerts = Get-DpaMonitorAlert -DatabaseId $databaseId -AlertId $alertId -IncludeAlertGroupAlerts
                $alerts | Should -HaveCount 2
                foreach ($alert in $alertId) {
                    $alerts.AlertId | Should -Contain $alert
                }
            }

            It 'should return the status of the alert' {
                $databaseId = 1
                $alertId = 1
                $alert = Get-DpaMonitorAlert -DatabaseId $databaseId -AlertId $alertId
                $alert.Status | Should -BeIn @('NORMAL', 'LOW', 'MEDIUM', 'HIGH')
            }
        }
    }
}