# PSDPA Solarwinds DPA PowerShell Module (Unofficial)
PSDPA is an open source PowerShell module for the Solarwinds DPA REST API. The
goal of the module is to provide complete PowerShell coverage for the API.

| Branch | Status |
|:--- |:--- |
| Master | [![Master Build Status](https://ci.appveyor.com/api/projects/status/i165eqibj5cvger3/branch/master?svg=true)](https://ci.appveyor.com/project/awickham10/psdpa/branch/master) [![Master Code Coverage](https://codecov.io/gh/awickham10/psdpa/branch/master/graph/badge.svg)](https://codecov.io/gh/awickham10/psdpa) |
| Development |[![Development Build Status](https://ci.appveyor.com/api/projects/status/i165eqibj5cvger3/branch/development?svg=true)](https://ci.appveyor.com/project/awickham10/psdpa/branch/development) [![Development Code Coverage](https://codecov.io/gh/awickham10/awickham10/branch/development/graph/badge.svg)](https://codecov.io/gh/awickham10/psdpa) |

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
* Get-DpaMonitor - Needs Help Documentation
* Start-DpaMonitor - Test Coverage Needed
* Stop-DpaMonitor - Test Coverage Needed
* Set-DpaMonitorPassword - Not Implemented
* Add-DpaMonitor - Not Implemented

### Licensing
* Get-DpaLicense - Needs Help Documentation
* Get-DpaMonitorLicense - Needs Help Documentation
* Set-DpaLicense - Not Implemented

### Annotations
* Get-DpaAnnotation - Complete
* Add-DpaAnnotation - Test Coverage Needed
* Remove-DpaAnnotation - Not Implemented
