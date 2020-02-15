# PSDPA Solarwinds DPA PowerShell Module (Unofficial)

PSDPA is an open source PowerShell module for the Solarwinds DPA REST API. The
goal of the module is to provide complete PowerShell coverage for the API.

| Branch      | Status                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Master      | [![Master Build Status](https://ci.appveyor.com/api/projects/status/i165eqibj5cvger3/branch/master?svg=true)](https://ci.appveyor.com/project/awickham10/psdpa/branch/master) [![Master Code Coverage](https://codecov.io/gh/awickham10/psdpa/branch/master/graph/badge.svg)](https://codecov.io/gh/awickham10/psdpa) [![PSGallery Version](https://img.shields.io/powershellgallery/v/PSDPA.svg?style=flat&label=PSGallery)](https://www.powershellgallery.com/packages/PSDPA)                                                                                                            |
| Development | [![Development Build Status](https://ci.appveyor.com/api/projects/status/i165eqibj5cvger3/branch/development?svg=true)](https://ci.appveyor.com/project/awickham10/psdpa/branch/development) [![Development Code Coverage](https://codecov.io/gh/awickham10/psdpa/branch/development/graph/badge.svg)](https://codecov.io/gh/awickham10/psdpa) [![Codacy Badge](https://api.codacy.com/project/badge/Grade/c303d5eae85a4840908206a4a1bcf92d)](https://www.codacy.com/app/awickham10/psdpa?utm_source=github.com&utm_medium=referral&utm_content=awickham10/psdpa&utm_campaign=Badge_Grade) |

## Instructions

```powershell
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

# Add an annotation to all monitors
Get-DpaMonitor | Add-DpaAnnotation -Title 'Patching' -Description 'Quarterly patching'
```

## Change Log
### 19.10.1
**New Version Scheme**
Switching over to YY.MM.X format to better articulate when the module has last been updated.

**New Commands**
-   Get-DpaAlert
-   Get-DpaAlertEmailTemplate
-   Get-DpaAlertGroup
-   Get-DpaMonitorAlert
-   Get-DpaMonitorAlertGroup
-   New-DpaAlertEmailTemplate
-   Remove-DpaAlertEmailTemplate
-   Remove-DpaAlertGroupMonitor
-   Set-DpaAlert
-   Set-DpaAlertEmailTemplate
-   Set-DpaMonitorPassword

## Functions

### Configuration

-   Set-DpaConfig - Complete
-   Get-DpaConfig - Complete

### Monitor

-   Get-DpaMonitor - Complete
-   Start-DpaMonitor - Complete
-   Stop-DpaMonitor - Complete
-   Set-DpaMonitorPassword - Test Coverage Needed
-   New-DpaMonitor - Test Coverage Needed

### Licensing

-   Get-DpaLicense - Complete
-   Get-DpaMonitorLicense - Complete
-   Set-DpaLicense - Not Implemented

### Annotations

-   Get-DpaAnnotation - Complete
-   Add-DpaAnnotation - Complete
-   Remove-DpaAnnotation - Complete
