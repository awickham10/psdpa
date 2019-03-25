<#

.SYNOPSIS
Adds a monitor to DPA.

.DESCRIPTION
Adds a database server to DPA to be monitored.

.PARAMETER ServerName
Server (Name or IP).

.PARAMETER Port
Port number.

.PARAMETER DatabaseType
Type of database server.

.PARAMETER Database
Name of the database to connect to (Azure SQL DB or Db2 only).

.PARAMETER DisplayName
Name to display in DPA.

.PARAMETER AmazonRDS
Indicates whether or not the server is an Amazon RDS server.

.PARAMETER Credential
Credential to use to connect to the server to setup DPA objects.

.PARAMETER CreateMonitoringUser
Indicates whether or not to create the monitoring user, or if it has already been created.

.PARAMETER MonitoringCredential
Credential DPA will use to monitor the server with.

.PARAMETER EnableException
Replaces user friendly yellow warnings with bloody red exceptions of doom! Use
this if you want the function to throw terminating errors you want to catch.

.EXAMPLE
$sysadminCredential = Get-Credential
$monitoringCredential = Get-Credential

New-DpaMonitor -ServerName 'mytestserver.database.windows.net' -Port 1433 -DatabaseType 'AzureSQLDB' -DisplayName 'mytestserver' -Database 'mytestdatabase' -Credential $sysadminCredential -MonitoringCredential $monitoringCredential -CreateMonitoringUser

Registers an Azure SQL DB for monitoring and creates the monitoring credential.

.NOTES
Author: Andrew Wickham ( @awickham )

Copyright: (C) Andrew Wickham, andrew@awickham.com
License: MIT https://opensource.org/licenses/MIT

#>
function New-DpaMonitor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $ServerName,

        [Parameter(Mandatory)]
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

        [Parameter(Mandatory)]
        [PSCredential] $Credential,

        [Parameter()]
        [switch] $CreateMonitoringUser,

        [Parameter()]
        [PSCredential] $MonitoringCredential,

        [Parameter()]
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