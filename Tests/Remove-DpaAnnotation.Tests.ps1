$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot\Shared.ps1

Describe "$CommandName Unit Tests" -Tag 'Unit' {
    Context "Command Design" {
        $command = Get-Command -Name $CommandName

        $testCases = @(
            @{ Name = 'Annotation'; Mandatory = $false }
        )
        It 'should have a <Name> parameter' -TestCases $testCases {
            param ( $Name , $Mandatory = $true )
            $command | Should -HaveParameter $Name -Mandatory:$Mandatory
        }
    }
}

Describe "$CommandName Integration Tests" -Tag 'Integration' {
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
            if ($Method -eq 'Delete' -and $Uri -like '*/databases/*/annotations/*') {
                return ''
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

        $annotation = New-Object -TypeName 'Annotation' -ArgumentList $monitor, ([PSCustomObject] @{
            id = 1
            createdBy = 'MockUser'
            type = 'Custom'
            title = 'Mock Annotation'
            description = 'This is a mock annotation'
            time = '2018-12-04T18:13:04-07:00'
        })

        It 'removes annotations by -Annotation' {
            { Remove-DpaAnnotation -Annotation $annotation -EnableException } | Should -Not -Throw

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }

        It 'removes annotations from the pipeline' {
            { $annotation | Remove-DpaAnnotation -EnableException } | Should -Not -Throw

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }

        It 'should throw an exception if the annotation does not exist' {
            <#
            We need to figure out how to have pester throw an error + response

            $annotation.AnnotationId = 9999
            { Remove-DpaAnnotation -Annotation $annotation -EnableException } | Should -Throw 'Invalid annotation ID'

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
            #>
        }
    }
}