function Set-DpaMonitorPassword {
    [CmdletBinding(DefaultParameterSetName = 'ByName', SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(ParameterSetName = 'ByDatabaseId', Mandatory)]
        [int[]] $DatabaseId,

        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [string[]] $MonitorName,

        [Parameter(ParameterSetName = 'ByMonitor', ValueFromPipeline)]
        [Monitor[]] $Monitor,

        [Parameter(Mandatory)]
        [SecureString] $SecurePassword,

        [Parameter()]
        [switch] $EnableException
    )

    begin {
        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $Monitor = Get-DpaMonitor -MonitorName $MonitorName
        } elseif ($PSCmdlet.ParameterSetName -eq 'ByDatabaseId') {
            $Monitor = Get-DpaMonitor -DatabaseId $DatabaseId
        }

        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
        $request = @{
            password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        }
    }

    process {
        foreach ($monitorObject in $Monitor) {
            if ($PSCmdlet.ShouldProcess($monitorObject.Name, 'Update Password')) {
                try {
                    $null = Invoke-DpaRequest -Endpoint "/databases/$($monitorObject.DatabaseId)/update-password" -Method 'PUT' -Request $request
                } catch {
                    Stop-PSFFunction -Message 'Could not update the monitor password' -ErrorRecord $_ -Target $monitorObject.Name -EnableException $EnableException
                }
            }
        }
    }
}