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
        Copy-Item -Path "$PSScriptRoot\Responses\Monitor\*" -Destination 'TestDrive:\'
    }

    InModuleScope 'PSDPA' {
        Context 'returns monitor data' {
            Mock -CommandName 'Get-DpaAccessToken' -MockWith {
                New-Object -TypeName 'AccessToken' -ArgumentList ([PSCustomObject] @{
                    access_token = 'myfakeaccesstoken'
                    token_type = 'bearer'
                    expires_in = 900
                })
            }

            Mock -CommandName 'Invoke-RestMethod' -MockWith {
                Get-Content -Path 'TestDrive:\MultipleMonitors.json' -Raw | ConvertFrom-Json
            }

            It 'should return a single monitor' {
                $databaseId = 1
                $monitor = Get-DpaMonitor -DatabaseId $databaseId
                $monitor | Should -HaveCount 1
                $monitor.DatabaseId | Should -BeExactly $databaseId

                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
            }

            It 'should get monitors by name' {
                $monitorName = 'MOCK-1'
                $monitor = Get-DpaMonitor -MonitorName $monitorName
                $monitor | Should -HaveCount 1
                $monitor.Name | Should -Be $monitorName

                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
            }

            Mock -CommandName 'Invoke-RestMethod' -MockWith {
                if ($Uri -like '*/databases/0/monitor-information') {
                    throw New-Object System.Web.HttpException 404, 'Not Found'
                }
                else {
                    Get-Content -Path 'TestDrive:\MultipleMonitors.json' -Raw | ConvertFrom-Json
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

            It 'should return an empty resultset when a monitor is not found' {
                Get-DpaMonitor -DatabaseId 0 -WarningAction 'SilentlyContinue' | Should -HaveCount 0

                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
            }

            It 'should not throw an exception when monitor is not found and -EnableException is not used' {
                { Get-DpaMonitor -DatabaseId 0 -WarningAction 'SilentlyContinue' } | Should -Not -Throw 'Not Found'

                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
            }

            It 'should throw an exception when monitor is not found and -EnableException is used' {
                { Get-DpaMonitor -DatabaseId 0 -EnableException } | Should -Throw 'Not Found'

                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
            }
        }
    }
}