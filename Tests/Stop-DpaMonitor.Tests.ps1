$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot\Shared.ps1

Describe "$CommandName Unit Tests" -Tag 'Unit' {
    Context "Command Design" {
        $command = Get-Command -Name $CommandName

        $testCases = @(
            @{ Name = 'DatabaseId'; Mandatory = $false },
            @{ Name = 'MonitorName'; Mandatory = $false },
            @{ Name = 'Monitor'; Mandatory = $false },
            @{ Name = 'EnableException'; Mandatory = $false }
        )
        It 'should have a <Name> parameter' -TestCases $testCases {
            param ( $Name , $Mandatory )
            $command | Should -HaveParameter $Name -Mandatory:$Mandatory
        }
    }
}

Describe "$CommandName Integration Tests" -Tag 'Integration' {
    BeforeAll {
        Copy-Item -Path "$PSScriptRoot\Responses\Monitor\" -Destination 'TestDrive:\' -Recurse -Force
    }

    BeforeEach {
        Set-Content -Path 'TestDrive:\Monitor\Mock1State.txt' -Value ''
    }

    InModuleScope 'PSDPA' {
        Mock -CommandName 'Get-DpaAccessToken' -MockWith {
            New-Object -TypeName 'AccessToken' -ArgumentList ([PSCustomObject] @{
                access_token = 'myfakeaccesstoken'
                token_type = 'bearer'
                expires_in = 900
            })
        }

        Mock -CommandName 'Invoke-RestMethod' -MockWith {
            Write-PSFMessage -Level 'Verbose' -Message "Invoke-RestMethod called to $Uri"
            if ($Uri -like '*/databases/1/monitor-information') {
                Get-Content -Path 'TestDrive:\Monitor\Mock1Monitor.json' -Raw | ConvertFrom-Json
            }
            elseif ($Uri -like '*/databases/monitor-information') {
                Get-Content -Path 'TestDrive:\Monitor\MultipleMonitors.json' -Raw | ConvertFrom-Json
            }
            elseif ($Uri -like '*/databases/*/monitor-status' -and $Method -eq 'PUT') {
                $json = $Body | ConvertFrom-Json
                if ($json.command -eq 'STOP') {
                    Set-Content -Path 'TestDrive:\Monitor\Mock1State.txt' -Value 'Stopped'
                }
            }
            else {
                throw "Mock for $Uri is not implemented"
            }
        }

        It 'starts a monitor by -DatabaseId' {
            $databaseId = 1
            Stop-DpaMonitor -DatabaseId $databaseId
            Get-Content -Path 'TestDrive:\Monitor\Mock1State.txt' | Should -Be 'Stopped'

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }

        It 'starts a monitor by -MonitorName' {
            $monitorName = 'MOCK-1'
            Stop-DpaMonitor -MonitorName $monitorName
            Get-Content -Path 'TestDrive:\Monitor\Mock1State.txt' | Should -Be 'Stopped'

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }

        $monitor = New-Object -TypeName 'SqlServerMonitor' -ArgumentList ([PSCustomObject] @{
            DbId = 1
            Name = 'MOCK-1'
            Ip = '127.0.0.1'
            JdbcUrlProperties = 'applicationIntent=readOnly'
            ConnectionProperties = ''
            DatabaseType = 'SQL Server'
            DatabaseVersion = '12.0.6205.1'
            DatabaseEdition = 'Enterprise Edition; core-based Licensing (64-bit)'
            MonitoringUser = 'ignite_next'
            DefaultDbLicenseCategory = 'DPACAT2'
            AssignedDbLicenseCategory = 'DPACAT2'
            AssignedVmLicenseCategory = ''
            MonitorState = 'Monitor Running'
            OldestMonitoringDate = '2018-12-04T00:00:00.000-07:00'
            LatestMonitoringDate = '2018-01-02T00:00:00.000-07:00'
            AgListenerName = ''
            AgClusterName = ''
            LinkedToVirtualMachine = $false
        })

        It 'starts a monitor by -Monitor' {
            Stop-DpaMonitor -Monitor $monitor
            Get-Content -Path 'TestDrive:\Monitor\Mock1State.txt' | Should -Be 'Stopped'

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }

        It 'starts a monitor from the pipeline' {
            $monitor | Stop-DpaMonitor
            Get-Content -Path 'TestDrive:\Monitor\Mock1State.txt' | Should -Be 'Stopped'

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }

        It 'does not throw an exception if the monitor could not be stopped and -EnableException is not used' {
            <#
            Need to figure out how to test this
            #>
        }

        It 'throws an exception if the monitor could not be stopped and -EnableException is used' {
            <#
            Need to figure out how to test this
            #>
        }
    }
}
