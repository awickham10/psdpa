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
    BeforeAll {
        Copy-Item -Path "$PSScriptRoot\Responses\Monitor\" -Destination 'TestDrive:\' -Recurse -Force
        Copy-Item -Path "$PSScriptRoot\Responses\Annotation\" -Destination 'TestDrive:\' -Recurse -Force
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
            if ($Uri -like '*/databases/*/monitor-information') {
                Get-Content -Path 'TestDrive:\Monitor\MultipleMonitors.json' -Raw | ConvertFrom-Json
            }
            elseif ($Uri -like '*/databases/monitor-information') {
                Get-Content -Path 'TestDrive:\Monitor\MultipleMonitors.json' -Raw | ConvertFrom-Json
            }
            elseif ($Uri -like '*/databases/1/annotations?startTime=2018-01-01*') {
                throw "Filtered by StartTime"
            }
            elseif ($Uri -like '*/databases/1/annotations?startTime=*&endTime=2018-01-01*') {
                throw "Filtered by EndTime"
            }
            elseif ($Uri -like '*/databases/1/annotations*') {
                Get-Content -Path 'TestDrive:\Annotation\Mock1Annotations.json' -Raw | ConvertFrom-Json
            }
            elseif ($Uri -like '*/databases/2/annotations*') {
                Get-Content -Path 'TestDrive:\Annotation\Mock2Annotations.json' -Raw | ConvertFrom-Json
            }
            else {
                throw "Mock for $Uri is not implemented"
            }
        }

        It 'gets annotations by -DatabaseId' {
            $databaseId = 1
            $annotation = Get-DpaAnnotation -DatabaseId $databaseId
            $annotation | Should -HaveCount 3
            $annotation.AnnotationId | Should -Be @(1, 2, 3)

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }

        It 'gets annotations by -MonitorName' {
            $monitorName = 'MOCK-2'
            $annotation = Get-DpaAnnotation -MonitorName $monitorName
            $annotation | Should -HaveCount 3
            $annotation.AnnotationId | Should -Be @(4, 5, 6)
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

        It 'gets annotations by -Monitor' {
            Get-DpaAnnotation -Monitor $monitor | Should -HaveCount 3
        }

        It 'gets annotations for multiple monitors' {
            $databaseId = @(1, 2)
            Get-DpaAnnotation -DatabaseId $databaseId | Should -HaveCount 6
        }

        It 'gets annotations from pipeline' {
            $monitor | Get-DpaAnnotation | Should -HaveCount 3
        }

        It 'filters by -StartTime' {
            { Get-DpaAnnotation -DatabaseId 1 -StartTime '2018-01-01' } | Should -Throw 'Filtered by StartTime'
        }

        It 'filters by -EndTime' {
            { Get-DpaAnnotation -DatabaseId 1 -EndTime '2018-01-01' } | Should -Throw 'Filtered by EndTime'
        }
    }
}