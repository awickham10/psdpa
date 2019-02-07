$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
. $PSScriptRoot\Shared.ps1

Describe "$CommandName Unit Tests" -Tag 'Unit' {
    Context "Command Design" {
        $command = Get-Command -Name $CommandName

        $testCases = @(
            @{Name = 'Product'},
            @{Name = 'Category'}
        )
        It 'should have a <Name> parameter' -TestCases $testCases {
            param ( $Name )
            $command | Should -HaveParameter $Name
        }
    }
}

Describe "$CommandName Integration Tests" -Tag 'Integration' {
    BeforeAll {
        Copy-Item -Path "$PSScriptRoot\Responses\Monitor\" -Destination 'TestDrive:\' -Recurse -Force
        Copy-Item -Path "$PSScriptRoot\Responses\License\" -Destination 'TestDrive:\' -Recurse -Force
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
            Get-Content -Path 'TestDrive:\License\Licenses.json' -Raw | ConvertFrom-Json
        }

        It 'returns all license information' {
            $licenses = Get-DpaLicense
            $licenses | Should -HaveCount 4

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }

        It 'returns a license by a product' {
            $license = Get-DpaLicense -Product 'DPACAT1'
            $license | Should -HaveCount 1

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }

        It 'returns licenses by products' {
            $products = @('DPACAT1', 'DPACAT2')
            $licenses = Get-DpaLicense -Product $products
            $licenses | Should -HaveCount 2
            $licenses.Product | Should -Be $products

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }

        It 'returns licenses by a category' {
            $category = 'DPA_DB'
            $licenses = Get-DpaLicense -Category $category
            $licenses | Should -HaveCount 3
            $licenses.Category | Select-Object -Unique | Should -Be $category

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }

        It 'returns licenses by categories' {
            $categories = @('DPA_DB', 'DPA_VM')
            $licenses = Get-DpaLicense -Category $categories
            $licenses | Should -HaveCount 4
            $licenses.Category | Select-Object -Unique | Should -Be $categories

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }

        It 'returns licenses by product and category' {
            $licenses = Get-DpaLicense -Product 'DPAVM' -Category 'DPA_DB'
            $licenses | Should -HaveCount 0

            Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1
        }
    }
}