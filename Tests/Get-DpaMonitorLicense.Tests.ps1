$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot\Shared.ps1

Describe "$CommandName Unit Tests" -Tag 'Unit' {
    Context "Command Design" {
        $command = Get-Command -Name $CommandName

        $testCases = @(
            @{ Name = 'DatabaseId'; Mandatory = $false },
            @{ Name = 'MonitorName'; Mandatory = $false },
            @{ Name = 'Monitor'; Mandatory = $false }
        )
        It 'should have a <Name> parameter' -TestCases $testCases {
            param ( $Name , $Mandatory = $true )
            $command | Should -HaveParameter $Name -Mandatory:$Mandatory
        }
    }
}

Describe "$CommandName Integration Tests" -Tag 'Integration' {
    BeforeAll {
        Copy-Item -Path "$PSScriptRoot\Responses\Monitor\" -Destination 'TestDrive:\' -Recurse -Force
        Copy-Item -Path "$PSScriptRoot\Responses\License\" -Destination 'TestDrive:\' -Recurse -Force
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
            elseif ($Uri -like '*/databases/1/licenses') {
                Get-Content -Path 'TestDrive:\License\Mock1MonitorLicense.json' -Raw | ConvertFrom-Json
            }
            elseif ($Uri -like '*/databases/2/licenses') {
                Get-Content -Path 'TestDrive:\License\Mock2MonitorLicense.json' -Raw | ConvertFrom-Json
            }
            else {
                throw "Mock for $Uri is not implemented"
            }
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

        It 'gets a monitor license by -DatabaseId' {
            $databaseId = 1
            $license = Get-DpaMonitorLicense -DatabaseId $databaseId

            $license.ServerName | Should -Be $monitor.Name

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }

        It 'gets a monitor license by -MonitorName' {
            $monitorName = 'MOCK-1'
            $license = Get-DpaMonitorLicense -MonitorName 'MOCK-1'

            $license.ServerName | Should -Be $monitor.Name

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }


        It 'gets annotations by -Monitor' {
            $license = Get-DpaMonitorLicense -Monitor $monitor
            $license.ServerName | Should -Be $monitor.Name

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }

        It 'gets annotations for multiple monitors' {
            $databaseId = @(1, 2)
            $licenses = Get-DpaMonitorLicense -DatabaseId $databaseId
            $licenses.ServerName | Should -Be @('MOCK-1', 'MOCK-2')

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }

        It 'gets annotations from pipeline' {
            $license = $monitor | Get-DpaMonitorLicense
            $license.ServerName | Should -Be $monitor.Name

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }
    }
}