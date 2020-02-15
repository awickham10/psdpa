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
    InModuleScope 'PSDPA' {
        It 'gets a monitor license by -DatabaseId' {
            $databaseId = 1
            $license = Get-DpaMonitorLicense -DatabaseId $databaseId
            $license.ServerName | Should -BeExactly $ENV:PSDPA_TEST_SQLINSTANCE
        }

        It 'gets a monitor license by -MonitorName' {
            $monitorName = $ENV:PSDPA_TEST_SQLINSTANCE
            $license = Get-DpaMonitorLicense -MonitorName $monitorName

            $license.ServerName | Should -Be $monitorName
        }


        It 'gets annotations by -Monitor' {
            $monitor = Get-DpaMonitor -MonitorName $ENV:PSDPA_TEST_SQLINSTANCE
            $license = Get-DpaMonitorLicense -Monitor $monitor
            $license.ServerName | Should -Be $monitor.name
        }

        It 'gets annotations for multiple monitors' {
            $databaseId = @(1, 2)
            $licenses = Get-DpaMonitorLicense -DatabaseId $databaseId
            $licenses.ServerName | Should -Be @('MOCK-1', 'MOCK-2')
        }

        It 'gets annotations from pipeline' {
            $monitor = Get-DpaMonitor -MonitorName $ENV:PSDPA_TEST_SQLINSTANCE
            $license = $monitor | Get-DpaMonitorLicense
            $license.ServerName | Should -Be $monitor.Name
        }
    }
}