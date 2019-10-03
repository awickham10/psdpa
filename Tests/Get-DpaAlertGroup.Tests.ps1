$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot\Shared.ps1

Describe "$CommandName Unit Tests" -Tag 'Unit' {
    Context "Command Design" {
        $command = Get-Command -Name $CommandName

        $testCases = @(
            @{ Name = 'AlertGroupId'; Mandatory = $false },
            @{ Name = 'AlertGroupName'; Mandatory = $false }
        )
        It 'should have a <Name> parameter' -TestCases $testCases {
            param ( $Name , $Mandatory = $true )
            $command | Should -HaveParameter $Name -Mandatory:$Mandatory
        }
    }
}

Describe "$CommandName Integration Tests" -Tag 'Integration' {
    InModuleScope 'PSDPA' {
        It 'gets all alert groups' {
            $alertGroups = Get-DpaAlertGroup
            $alertGroups | Should -HaveCount 2
        }

        It 'gets alert groups by -AlertGroupId' {
            $alertGroupId = 1
            $alertGroup = Get-DpaAlertGroup -AlertGroupId $alertGroupId
            $alertGroup | Should -HaveCount 1
            $alertGroup.AlertGroupId | Should -BeExactly $alertGroupId
        }

        It 'gets multiple alert groups by -AlertGroupId' {
            $alertGroupId = @(1, 2)
            $alertGroup = Get-DpaAlertGroup -AlertGroupId $alertGroupId
            $alertGroup | Should -HaveCount $alertGroupId.Count
            $alertGroupId | % { $alertGroup.AlertGroupId | Should -Contain $_ }
        }

        It 'gets alert groups by -Name' {
            $alertGroupName = 'SQL'
            $alertGroup = Get-DpaAlertGroup -AlertGroupName $alertGroupName
            $alertGroup | Should -HaveCount 1
            $alertGroup.Name | Should -Be $alertGroupName
        }

        It 'errors with an invalid -AlertGroupId' {
            { Get-DpaAlertGroup -AlertGroupid 99 -EnableException } | Should -Throw 'The remote server returned an error: (422).'
        }

        It 'includes alerts in the response' {
            $alertGroupId = 1
            $alertGroup = Get-DpaAlertGroup -AlertGroupId $alertGroupId
            $alertGroup.Alerts | Should -HaveCount 2
        }
    }
}