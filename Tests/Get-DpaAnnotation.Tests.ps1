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
    Mock -CommandName 'Invoke-RestMethod' -MockWith {
        Get-MockJsonResponse -Tag 'Annotation' -Response 'SingleAnnotation'
    }

    It 'gets a single annotation' {

    }

    Mock -CommandName 'Invoke-RestMethod' -MockWith {
        Get-MockJsonResponse -Tag 'Annotation' -Response 'MultipleAnnotations'
    }

    It 'gets multiple annotations' {

    }

    It 'gets annotations for multiple monitors' {

    }

    it 'filters by -StartTime' {

    }

    it 'filters by -EndTime' {

    }

    it 'throws an exception when the monitor is not found' {

    }
}