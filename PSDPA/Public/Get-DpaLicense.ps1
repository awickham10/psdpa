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
            Product = $license.licenseProduct
            Category = $license.licenseCategory
            Available = [int] $license.licensesAvailable
            Consumed = [int] $license.licensesConsumed
            Total = [int] $license.licensesAvailable + [int] $license.licensesConsumed
        }
    }
}