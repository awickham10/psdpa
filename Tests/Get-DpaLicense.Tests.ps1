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
    InModuleScope 'PSDPA' {
        It 'returns all license information' {
            $licenses = Get-DpaLicense
            $licenses.Count | Should -BeGreaterThan 0
        }

        It 'returns a license by a product' {
            $license = Get-DpaLicense -Product 'DPACAT1'
            $license.Count | Should -BeGreaterThan 0
        }

        It 'returns licenses by products' {
            $products = @('DPACAT1', 'DPACAT2')
            $licenses = Get-DpaLicense -Product $products
            $licenses.Count | Should -BeGreaterOrEqual 2
            $licenses.Product | Should -Be $products
        }

        It 'returns licenses by a category' {
            $category = 'DPA_DB'
            $licenses = Get-DpaLicense -Category $category
            $licenses | Should -HaveCount 3
            $licenses.Category | Select-Object -Unique | Should -Be $category
        }

        It 'returns licenses by categories' {
            $categories = @('DPA_DB', 'DPA_VM')
            $licenses = Get-DpaLicense -Category $categories
            $licenses | Should -HaveCount 4
            $licenses.Category | Select-Object -Unique | Should -Be $categories
        }

        It 'returns licenses by product and category' {
            $licenses = Get-DpaLicense -Product 'DPAVM' -Category 'DPA_DB'
            $licenses | Should -HaveCount 0
        }
    }
}