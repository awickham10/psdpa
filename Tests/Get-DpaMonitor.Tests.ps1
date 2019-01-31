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
        Initialize-TestDrive
    }

    Context 'returns monitor data' {
        Mock -CommandName 'Invoke-RestMethod' -MockWith {
            return @{data = Get-Content -Path TestDrive:\SingleMonitor.json -Raw | ConvertFrom-Json | ConvertTo-PSObject}
        }

        It 'should return a single monitor' {
            $databaseId = 1
            $monitor = @(Get-DpaMonitor -DatabaseId $databaseId)
            $monitor | Should -HaveCount 1
            $monitor.DbId | Should -BeExactly $databaseId
        }

        It 'should return multiple monitors' {
            $monitor = Get-DpaMonitor -DatabaseId $databaseId
            $monitor | Should -HaveCount 2
        }

        It 'should return all monitors' {
            $monitors = Get-DpaMonitor
            $monitor | Should -HaveCount 3
        }

        It 'should return nothing when the monitor is not found' {
            Get-DpaMonitor -DatabaseId 0 | Should -BeNullOrEmpty
        }
    }
}