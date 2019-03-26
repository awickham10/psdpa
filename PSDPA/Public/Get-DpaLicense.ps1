<#

.SYNOPSIS
Gets a DPA licensing summary

.DESCRIPTION
Gets a product breakdown of licenses from DPA. This includes product, category,
number of licenses available, used, and total.

.PARAMETER Product
Product to get licenses for. If not specified, all products will be included.
This is either DPACAT1, DPACAT2, DPAAzureSQL, or DPAVM.

.PARAMETER Category
Category of products to get licenses for. At the moement this is either
database (DPA_DB) or VM (DPA_VM).

.EXAMPLE
Get-DpaLicense

Gets a summary for all license types.

.EXAMPLE
Get-DpaLicense -Product DPACAT1

Gets DPACAT1 licensing.

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>

function Get-DpaLicense {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet('DPACAT1', 'DPACAT2', 'DPAAzureSQL', 'DPAVM')]
        [string[]] $Product,

        [Parameter()]
        [ValidateSet('DPA_DB', 'DPA_VM')]
        [string[]] $Category
    )

    $endpoint = 'databases/licenses/installed'

    $response = Invoke-DpaRequest -Endpoint $endpoint -Method 'GET'
    $response = $response.data

    if ($PSBoundParameters.ContainsKey('Product')) {
        $response = $response | Where-Object { $_.licenseProduct -in $Product }
    }

    if ($PSBoundParameters.ContainsKey('Category')) {
        $response = $response | Where-Object { $_.licenseCategory -in $Category }
    }

    foreach ($license in $response) {
        [PSCustomObject] @{
            Product   = $license.licenseProduct
            Category  = $license.licenseCategory
            Available = [int] $license.licensesAvailable
            Consumed  = [int] $license.licensesConsumed
            Total     = [int] $license.licensesAvailable + [int] $license.licensesConsumed
        }
    }
}