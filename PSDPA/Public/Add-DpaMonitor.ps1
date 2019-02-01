function Add-DpaMonitor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $ServerName,

        [Parameter()]
        $Port,

        [Parameter(Mandatory)]
        [ValidateSet('AzureSQLDB', 'Db2', 'MySQL', 'Oracle', 'SQLServer', 'Sybase')]
        $DatabaseType,

        [Parameter()]
        $DisplayName,

        [Parameter(Mandatory)]
        [PSCredential] $RegisterCredential,

        [Parameter()]
        [PSCredential] $MonitoringCredential,

        [switch] $EnableException
    )

    $request = @{
        serverName = $ServerName
        databaseType = $DatabaseType.ToUpper()
    }

    if ($PSBoundParameters.ContainsKey('Port')) {
        $request['port'] = $Port
    }

    if ($DatabaseType -eq 'SQLServer') {
        $isDomainUser = $RegisterCredential.GetNetworkCredential().Domain -ne ''
        if ($isDomainUser) {
            $request['sysadminIsWindowsAuth'] = $true
            $request['monitoringUserIsNew'] = $false
        }
    }

    $request['sysAdminUser'] = $RegisterCredential.UserName
    $request['sysAdminPassword'] = $RegisterCredential.GetNetworkCredential().Password

    if ($DatabaseType -ne 'Db2') {
        if ($PSBoundParameters.ContainsKey('MonitoringCredential') -and $DatabaseType -ne 'Db2') {
            $request['monitoringUser'] = $MonitoringCredential.UserName
            $request['monitoringUserPassword'] = $MonitoringCredential.GetNetworkCredential().Password
        }
        else {
            $request['monitoringUser'] = $RegisterCredential.UserName
            $request['monitoringUserPassword'] = $RegisterCredential.GetNetworkCredential().Password
        }
    }

    $response = Invoke-DpaRequest -Endpoint '/databases/register-monitor' -Request $request -Method 'POST'
    if ($response.Result -eq 'SUCCESS') {
        Get-DpaMonitor -DatabaseId $response.DatabaseId
    }
}