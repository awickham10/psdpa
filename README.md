# PSDPA Solarwinds DPA PowerShell Module (Unofficial)
[![Master Build Status](https://ci.appveyor.com/api/projects/status/i165eqibj5cvger3/branch/master?svg=true)](https://ci.appveyor.com/project/sqlmdr/psdpa/branch/master)
[![Development Build Status](https://ci.appveyor.com/api/projects/status/i165eqibj5cvger3/branch/development?svg=true)](https://ci.appveyor.com/project/sqlmdr/psdpa/branch/development)

PSDPA is an open source PowerShell module for the Solarwinds DPA REST API. The
goal of the module is to provide complete PowerShell coverage for the API.

## Instructions
``` powershell
# Install the PSDPA module from the gallery
Install-Module PSDPA

# Import the PSDPA module
Import-Module PSDPA

# Get commands available
Get-Command -Module PSDPA

# Configure the module
Set-DpaConfig -BaseUri 'https://yourdpaserver:8124/iwc/api' -RefreshToken 'yourprivatestring'

# Get listing of monitors
Get-DpaMonitor
```

## Functions
### Configuration
* Set-DpaConfig - Complete
* Get-DpaConfig - Complete

### Monitor
* Get-DpaMonitor - Test Coverage Needed
* Start-DpaMonitor - Test Coverage Needed
* Stop-DpaMonitor - Test Coverage Needed
* Set-DpaMonitorPassword - Not Implemented
* Add-DpaMonitor - Not Implemented

### Licensing
* Get-DpaLicense - Not Implemented
* Set-DpaLicense - Not Implemented

### Annotations
* Get-DpaAnnotation - Test Coverage Needed
* Add-DpaAnnotation - Test Coverage Needed
* Remove-DpaAnnotation - Not Implemented