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
Set-DpaConfig -BaseUri 'http://yourdpaserver:8124/iwc/api' -RefreshToken 'yourprivatestring'

# Get listing of monitors
Get-DpaMonitor
```

## Functions
### Configuration
* Set-DpaConfig
* Get-DpaConfig

### Authentication
* Get-DpaToken

### Monitor
* Get-DpaMonitor
* Start-DpaMonitor
* Stop-DpaMonitor
* Set-DpaMonitorPassword
* Add-DpaMonitor

### Licensing
* Get-DpaLicense
* Set-DpaLicense

### Annotations
* Get-DpaAnnotation
* Add-DpaAnnotation
* Remove-DpaAnnotation