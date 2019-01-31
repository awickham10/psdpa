<#
.SYNOPSIS
Get monitor information

.DESCRIPTION
Gets information about all montiors or specific monitors (e.g. name, IP,
connection string, type, version, edition).

.PARAMETER DatabaseId
If specified, returns monitor information for that specific database.

.EXAMPLE
Gets all monitors

Get-DpaMonitor

.EXAMPLE
Gets a specific monitor

Get-DpaMonitor -DatabaseId 1

.EXAMPLE
Gets a set of monitors

Get-DpaMonitor -DatabaseId 1,2,3

#>
function Get-DpaMonitor {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        [Parameter(ParameterSetName = 'ByDatabaseId')]
        [ValidateNotNullOrEmpty()]
        $DatabaseId
    )

    if ($PSCMdlet.ParameterSetName -eq 'ByDatabaseId') {
        $uriPart = "databases/$DatabaseId/monitor-information"
    }
    else {
        $uriPart = 'databases/monitor-information'
    }

    $uri = Get-DpaBaseUri
    $uri += "/$uriPart"

    try {
        $response = Invoke-RestMethod -Uri $uri -Method 'Get' -Headers $headers
        $response.data
    }
    catch {
        $_.Exception.ToString()
    }
}
