$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot\Shared.ps1

Describe "$CommandName Unit Tests" -Tag 'Unit' {
    Context "Command Design" {
        $command = Get-Command -Name $CommandName

        $testCases = @(
            @{Name = 'DatabaseId'}
        )
        It 'should have a <Name> parameter' -TestCases $testCases {
            param ( $Name )
            $command | Should -HaveParameter $Name
        }
    }
}

Describe "$CommandName Integration Tests" -Tag 'Integration' {
    InModuleScope 'PSDPA' {
        Context 'returns monitor data' {
            It 'should return a single monitor' {
                $databaseId = 1
                $monitor = Get-DpaMonitor -DatabaseId $databaseId
                $monitor | Should -HaveCount 1
                $monitor.DatabaseId | Should -BeExactly $databaseId
            }

            It 'should get monitors by name' {
                $monitorName = $ENV:PSDPA_TEST_SQLINSTANCE
                $monitor = Get-DpaMonitor -MonitorName $monitorName
                $monitor | Should -HaveCount 1
                $monitor.Name | Should -Be $monitorName
            }

            It 'should return multiple monitors' {
                $databaseId = @(1, 2)
                $monitors = Get-DpaMonitor -DatabaseId $databaseId
                $monitors | Should -HaveCount 2
            }

            It 'should return all monitors' {
                $monitors = Get-DpaMonitor
                $monitors | Should -HaveCount 2
            }

            It 'should return an empty resultset when a monitor is not found' {
                $montiors = Get-DpaMonitor -DatabaseId 0 -WarningAction 'SilentlyContinue'
                $monitors | Should -BeNullOrEmpty
            }
        }
    }
}