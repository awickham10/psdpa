$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot\Shared.ps1

Describe "$CommandName Unit Tests" -Tag 'Unit' {
    Context "Command Design" {
        $command = Get-Command -Name $CommandName

        $testCases = @(
            @{ Name = 'DatabaseId'; Mandatory = $false },
            @{ Name = 'MonitorName'; Mandatory = $false },
            @{ Name = 'Monitor'; Mandatory = $false }
            @{ Name = 'StartTime'; Mandatory = $false },
            @{ Name = 'EndTime'; Mandatory = $false }
        )
        It 'should have a <Name> parameter' -TestCases $testCases {
            param ( $Name , $Mandatory = $true )
            $command | Should -HaveParameter $Name -Mandatory:$Mandatory
        }

        It 'should default StartTime to 30 days ago' {
            # Not sure how to test this
        }

        It 'should default EndTime to now' {
            # Not sure how to test this
        }
    }
}

Describe "$CommandName Integration Tests" -Tag 'Integration' {
    InModuleScope 'PSDPA' {
        It 'gets annotations by -DatabaseId' {
            $databaseId = 1
            $annotation = Get-DpaAnnotation -DatabaseId $databaseId
            $annotation.Count | Should -BeGreaterOrEqual 1
            $annotation[0].GetType().Name | Should -Be 'Annotation'
        }

        It 'gets annotations by -MonitorName' {
            $monitorName = $ENV:PSDPA_TEST_SQLINSTANCE
            $annotation = Get-DpaAnnotation -MonitorName $monitorName
            $annotation.Count | Should -BeGreaterOrEqual 1
            $annotation[0].GetType().Name | Should -Be 'Annotation'
        }

        It 'gets annotations by -Monitor' {
            $monitor = Get-DpaMonitor -MonitorName $ENV:PSDPA_TEST_SQLINSTANCE
            $annotations = Get-DpaAnnotation -Monitor $monitor
            $annotations.Count | Should -BeGreaterOrEqual 1
            $annotations[0].GetType().Name | Should -Be 'Annotation'
        }

        It 'gets annotations for multiple monitors' {
            $databaseId = @(1, 2)
            $annotations = Get-DpaAnnotation -DatabaseId $databaseId
            $annotations.Count | Should -BeGreaterOrEqual 1
            $annotations[0].GetType().Name | Should -Be 'Annotation'
        }

        It 'gets annotations from pipeline' {
            $monitor = Get-DpaMonitor -MonitorName $ENV:PSDPA_TEST_SQLINSTANCE
            $annotations = $monitor | Get-DpaAnnotation
            $annotations.Count | Should -BeGreaterOrEqual 1
            $annotations[0].GetType().Name | Should -Be 'Annotation'
        }

        It 'filters by -StartTime' {
            $monitor = Get-DpaMonitor -MonitorName $ENV:PSDPA_TEST_SQLINSTANCE
            $annotations = Get-DpaAnnotation -Monitor $monitor
            
            $minStartTime = $annotations.Time | Sort-Object | Select-Object -First 1
            $newMinStartTime = $minStartTime.AddSeconds(1)

            $startTimeAnnotations = Get-DpaAnnotation -Monitor $monitor -StartTime $newMinStartTime
            
            # count should have gone down by one
            $startTimeAnnotations.Count | Should -BeLessThan $annotations.Count

            # check all the start times
            foreach ($startTimeAnnotation in $startTimeAnnotations) {
                $startTimeAnnotation.Time | Should -BeGreaterOrEqual $newMinStartTime
            }
        }

        It 'filters by -EndTime' {
            $monitor = Get-DpaMonitor -MonitorName $ENV:PSDPA_TEST_SQLINSTANCE
            $annotations = Get-DpaAnnotation -Monitor $monitor
            
            $maxStartTime = $annotations.Time | Sort-Object -Descending | Select-Object -First 1
            $newMaxStartTime = $maxStartTime.AddSeconds(-1)

            $endTimeAnnotations = Get-DpaAnnotation -Monitor $monitor -EndTime $newMaxStartTime
            
            # count should have gone down by one
            $endTimeAnnotations.Count | Should -BeLessThan $annotations.Count

            # check all the start times
            foreach ($endTimeAnnotation in $endTimeAnnotations) {
                $endTimeAnnotation.Time | Should -BeLessThan $newMaxStartTime
            }
        }

        It 'has the monitor object associated with it' {
            $annotation = Get-DpaAnnotation -DatabaseId 1
            $annotation.Monitor | Should -Not -BeNullOrEmpty
            $annotation.Monitor[0] -is [Monitor] | Should -Be $true
        }
    }
}