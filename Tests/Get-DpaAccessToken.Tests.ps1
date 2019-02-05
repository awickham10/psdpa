$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot\Shared.ps1

Describe "$CommandName Integration Tests" -Tag 'Integration' {
    Context 'valid token' {
        Mock -CommandName 'Invoke-RestMethod' -MockWith {
            Get-MockJsonResponse -Tag 'AccessToken' -Response 'GetAccessToken'
        }

        It 'returns an access token' {
            $response = Get-DpaAccessToken
            $response.AccessToken | Should -Not -BeNullOrEmpty

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }
    }

    Context 'invalid token' {
        Mock -CommandName 'Invoke-RestMethod' -MockWith {
            throw 'Unauthorized'
        }

        It 'should throw an exception when using -EnableException' {
            { Get-DpaAccessToken -EnableException } | Should -Throw 'Unauthorized'

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }
    }
}
