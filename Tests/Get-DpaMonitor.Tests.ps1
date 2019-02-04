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
    BeforeAll {
        Initialize-TestDrive -Tag Monitor
    }

    InModuleScope 'PSDPA' {
        Context 'returns monitor data' {
            Mock -CommandName 'Invoke-RestMethod' -MockWith {
                Get-JsonResponse -Tag Monitor -Response 'SingleMonitor'
            }

            It 'should return a single monitor' {
                $databaseId = 1
                $monitor = @(Get-DpaMonitor -DatabaseId $databaseId)
                $monitor | Should -HaveCount 1
                $monitor.DbId | Should -BeExactly $databaseId
            }

            Mock -CommandName 'Invoke-RestMethod' -MockWith {
                if ($Uri -like '*/databases/0/monitor-information') {
                    throw New-Object System.Web.HttpException 404, 'Not Found'
                }
                else {
                    Get-JsonResponse -Tag Monitor -Response 'MultipleMonitors'
                }
            }

            It 'should return multiple monitors' {
                $databaseId = @(1, 2)
                $monitors = Get-DpaMonitor -DatabaseId $databaseId
                $monitors | Should -HaveCount 2
            }

            It 'should return all monitors' {
                $monitors = Get-DpaMonitor
                $monitors | Should -HaveCount 3
            }

            It 'should return nothing when the monitor is not found' {
                Get-DpaMonitor -DatabaseId 0 -WarningAction SilentlyContinue | Should -BeNullOrEmpty
            }
        }
    }
}