function New-DpaMonitor {
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
        $Database,

        [Parameter()]
        $DisplayName,

        [Parameter()]
        [switch] $AmazonRDS,

        [Parameter()]
        [string] $RepositoryTableSpace,

        [Parameter()]
        [string] $JdbcUrlProperties,

        [Parameter()]
        [string] $ConnectionProperties,

        [Parameter(Mandatory)]
        [PSCredential] $Credential,

        [Parameter()]
        [switch] $CreateMonitoringUser,

        [Parameter()]
        [PSCredential] $MonitoringCredential,

        [switch] $EnableException
    )

    $oracleOnlyParameters = @(
        'ServiceNameOrSID',
        'MonitoringUserTableSpace',
        'MonitoringUserTempTableSpace',
        'SysPassword',
        'SysBypass',
        'OracleEBusinessEnabled'
    )
    foreach ($oracleOnlyParameter in $oracleOnlyParameters) {
        if ($DatabaseType -ne 'Oracle' -and $PSBoundParameters.ContainsKey($oracleOnlyParameter)) {
            Write-PSFMessage -Level Warning -Message "The $oracleOnlyParameter parameter is not available for $DatabaseType. It will be ignored."
        }
    }

    if ($DatabaseType -notin @('AzureSQLDB', 'Db2') -and $PSBoundParameters.ContainsKey('Database')) {
        Write-PSFMessage -Level Warning -Message "The Database parameter is not available for $DatabaseType. It will be ignored."
    }

    if ($DatabaseType -eq 'Db2' -and $PSBoundParameters.ContainsKey('MonitoringCredential')) {
        Write-PSFMessage -Level Warning -Message "The MontioringCredential parameter is not available for Db2. It will be ignored."
    }

    $request = @{
        serverName   = $ServerName
        databaseType = $DatabaseType.ToUpper()
    }

    if ($PSBoundParameters.ContainsKey('Port')) {
        $request['port'] = $Port
    }

    if ($AmazonRDS.IsPresent) {
        $request['amazonRds'] = $AmazonRDS
    }

    if ($PSBoundParameters.ContainsKey('RepositoryTableSpace')) {
        $request['repositoryTableSpace'] = $RepositoryTableSpace
    }

    if ($PSBoundParameters.ContainsKey('JdbcUrlProperties')) {
        $request['jdbcUrlProperties'] = $JdbcUrlProperties
    }

    if ($PSBoundParameters.ContainsKey('ConnectionProperties')) {
        $request['connectionProperties'] = $ConnectionProperties
    }

    if ($DatabaseType -eq 'SQLServer') {
        $isDomainUser = $Credential.GetNetworkCredential().Domain -ne ''
        if ($isDomainUser) {
            $request['sysadminIsWindowsAuth'] = $true
            $request['monitoringUserIsNew'] = $false
        }
    }

    $request['sysAdminUser'] = $Credential.UserName
    $request['sysAdminPassword'] = $Credential.GetNetworkCredential().Password

    if ($CreateMonitoringUser) {
        $request['monitoringUserIsNew'] = $true
    } else {
        $request['monitoringUserIsNew'] = $false
    }

    if ($PSBoundParameters.ContainsKey('Database') -and $DatabaseType -in @('AzureSQLDB', 'Db2')) {
        $request['database'] = $Database
    }

    if ($DatabaseType -ne 'Db2') {
        if ($PSBoundParameters.ContainsKey('MonitoringCredential') -and $DatabaseType -ne 'Db2') {
            $request['monitoringUser'] = $MonitoringCredential.UserName
            $request['monitoringUserPassword'] = $MonitoringCredential.GetNetworkCredential().Password
        } else {
            $request['monitoringUser'] = $Credential.UserName
            $request['monitoringUserPassword'] = $Credential.GetNetworkCredential().Password
        }
    }

    try {
        $response = Invoke-DpaRequest -Endpoint '/databases/register-monitor' -Request $request -Method 'POST'
    } catch {
        $responseStream = $_.Exception.Response.GetResponseStream()
        $streamReader = New-Object System.IO.StreamReader $responseStream

        $response = $streamReader.ReadToEnd() | ConvertFrom-Json

        Stop-PSFFunction -Message $response.messages[0].reason -ErrorRecord $_
        return
    }

    if ($response.Result -eq 'SUCCESS') {
        Get-DpaMonitor -DatabaseId $response.DatabaseId
    }
}