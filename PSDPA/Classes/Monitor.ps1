class Monitor {
    [int] $DatabaseId
    [string] $Name
    [string] $DatabaseType
    [string] $State
    [string] $ConnectionProperties
    [string] $DefaultDbLicenseCategory
    [string] $AssignedDbLicenseCategory
    [string] $IpAddress
    [DateTime] $OldestMonitoringDate
    [DateTime] $LatestMonitoringDate
    [string] $JdbcUrlProperties
    [string] $AssignedVmLicenseCategory
    [string] $MonitoringUser
    [bool] $AmazonRds
    [string] $DatabaseVersion
    [bool] $LinkedToVm
    [int] $Port
    [string] $DatabaseEdition

    Monitor ([PSCustomObject] $Json) {
        $type = $this.GetType()
        if ($type -eq [Monitor]) {
            throw("Class $type must be inherited")
        }

        $this.DatabaseId = $Json.dbId
        $this.DatabaseType = $Json.databaseType
        $this.Name = $Json.name
        $this.IpAddress = $Json.ip
        $this.Port = $Json.port
        $this.JdbcUrlProperties = $Json.jdbcUrlProperties
        $this.ConnectionProperties = $Json.connectionProperties
        $this.DatabaseVersion = $Json.databaseVersion
        $this.DatabaseEdition = $Json.databaseEdition
        $this.MonitoringUser = $Json.monitoringUser
        $this.DefaultDbLicenseCategory = $Json.defaultDbLicenseCategory
        $this.AssignedDbLicenseCategory = $Json.assignedDbLicenseCategory
        $this.AssignedVmLicenseCategory = $Json.assignedVmLicenseCategory
        $this.State = $Json.monitorState
        $this.OldestMonitoringDate = $Json.oldestMonitoringDate
        $this.LatestMonitoringDate = $Json.latestMonitoringDate
        $this.LinkedToVm = $Json.linkedToVirtualMachine
    }

    [void] Stop () {
        $null = Stop-DpaMonitor -DatabaseId $this.DatabaseId
    }

    [void] Start() {
        $null = Start-DpaMonitor -Monitor $this
    }

    [string] ToString() {
        return $this.Name
    }
}

class OracleMonitor : Monitor {
    OracleMonitor ([PSCustomObject] $Json) : base ($Json) {}
}

class SqlServerMonitor : Monitor {
    [string] $AgListenerName
    [string] $AgClusterName

    SqlServerMonitor ([PSCustomObject] $Json) : base ($Json) {
        $this.AgListenerName = $Json.agListenerName
        $this.AgClusterName = $Json.agClusterName
    }
}

class MonitorFactory {
    static [Monitor[]] $Monitors

    static [Object] getByType ([Object] $O) {
        return [MonitorFactory]::Monitors.Where({$_ -is $O})
    }

    static [Object] getByName ([String] $Name) {
        return [MonitorFactory]::Monitors.Where({$_.Name -eq $Name})
    }

    [Monitor] New ([PSCustomObject] $Json) {
        $type = $Json.databaseType.Replace(' ', '') + 'Monitor'

        return (New-Object -TypeName "$type" -ArgumentList $Json)
    }
}
