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
        New-Object -TypeName 'License' -ArgumentList $license
    }
}