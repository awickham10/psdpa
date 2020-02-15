$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot\Shared.ps1

Describe "$CommandName Integration Tests" -Tag 'Integration' {
    InModuleScope 'PSDPA' {
        Context 'valid token' {
            It 'returns an access token' {
                $response = Get-DpaAccessToken
                $response.AccessToken | Should -Not -BeNullOrEmpty
            }
        }

        Context 'invalid token' {
            It 'should throw an exception when using -EnableException' {
                Mock -CommandName 'Get-DpaConfig' -ParameterFilter { $Name -eq 'refreshtoken' } -MockWith {
                    return [PSCustomObject]@{
                        value = 'ThisIsATotallyInvalidRefreshToken'
                    }
                }

                { Get-DpaAccessToken -EnableException } | Should -Throw

                Assert-MockCalled -CommandName 'Get-DpaConfig' -Times 1
            }
        }
    }
}
