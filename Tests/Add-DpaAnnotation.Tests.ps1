$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot\Shared.ps1

Describe "$CommandName Unit Tests" -Tag 'Unit' {
    Context "Command Design" {
        $command = Get-Command -Name $CommandName

        $testCases = @(
            @{ Name = 'DatabaseId'; Mandatory = $true },
            @{ Name = 'Time'; Mandatory = $false },
            @{ Name = 'Description'; Mandatory = $true },
            @{ Name = 'CreatedBy'; Mandatory = $false }
        )
        It 'should have a <Name> parameter' -TestCases $testCases {
            param ( $Name , $Mandatory = $true )
            $command | Should -HaveParameter $Name -Mandatory:$Mandatory
        }
    }
}

Describe "$CommandName Integration Tests" -Tag 'Integration' {
    Context 'Azure SQL DB' {
        BeforeAll {
            # set the start time and remove ticks since DPA doesn't support them
            $contextStartTime = Get-Date
            $contextStartTime = $contextStartTime.AddTicks(-($contextStartTime.Ticks % [TimeSpan]::TicksPerSecond));

            # get our test monitor
            $monitor = Get-DpaMonitor -MonitorName 'PSDPATESTDB01@PSDPATEST01'

            # default annotation parameters to use for tests
            $annotationParams = @{
                Monitor = $monitor
                Title = 'Testing API'
                Description = 'This is a test of Add-DpaAnnotation'
                CreatedBy = 'Test User'
                Time = $contextStartTime
            }
        }

        BeforeEach {
            $script:annotation = $null
        }

        It 'should add an annotation' {
            { $script:annotation = Add-DpaAnnotation @annotationParams -EnableException } | Should -Not -Throw

            foreach ($annotationParam in $annotationParams.Keys) {
                $annotation.$annotationParam | Should -BeExactly $annotationParams[$annotationParam]
            }

            $annotation.Type | Should -Be 'API'
        }

        It 'should add an annotation when piping a monitor' {
            $thisAnnotationParams = $annotationParams.Clone()
            $thisAnnotationParams.Remove('Monitor')

            { $script:annotation = $monitor | Add-DpaAnnotation @thisAnnotationParams -EnableException } | Should -Not -Throw

            foreach ($annotationParam in $thisAnnotationParams.Keys) {
                $annotation.$annotationParam | Should -BeExactly $thisAnnotationParams[$annotationParam]
            }

            $annotation.DatabaseId | Should -BeExactly $monitor.DatabaseId
            $annotation.Type | Should -Be 'API'
        }

        It 'should default CreatedBy to the current user' {
            $thisAnnotationParams = $annotationParams.Clone()
            $thisAnnotationParams.Remove('CreatedBy')

            { $script:annotation = Add-DpaAnnotation @thisAnnotationParams -EnableException } | Should -Not -Throw

            foreach ($annotationParam in $thisAnnotationParams.Keys) {
                $annotation.$annotationParam | Should -BeExactly $thisAnnotationParams[$annotationParam]
            }

            $annotation.CreatedBy | Should -Be $env:USERNAME
        }

        It 'should default Time to the current time' {
            $thisAnnotationParams = $annotationParams.Clone()
            $thisAnnotationParams.Remove('Time')

            { $script:annotation = Add-DpaAnnotation @thisAnnotationParams -EnableException } | Should -Not -Throw

            foreach ($annotationParam in $thisAnnotationParams.Keys) {
                $annotation.$annotationParam | Should -BeExactly $thisAnnotationParams[$annotationParam]
            }

            # give ourselves a 10 minute swing on time just in case server times vary
            $currentTime = Get-Date
            $annotation.Time | Should -BeGreaterThan $currentTime.AddMinutes(-5)
            $annotation.Time | Should -BeLessThan $currentTime.AddMinutes(5)
        }
    }
}