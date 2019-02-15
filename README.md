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
```

## Functions

### Configuration

-   Set-DpaConfig - Complete
-   Get-DpaConfig - Complete

### Monitor

-   Get-DpaMonitor - Complete
-   Start-DpaMonitor - Complete
-   Stop-DpaMonitor - Complete
-   Set-DpaMonitorPassword - Not Implemented
-   Add-DpaMonitor - Not Implemented

### Licensing

-   Get-DpaLicense - Complete
-   Get-DpaMonitorLicense - Complete
-   Set-DpaLicense - Not Implemented

### Annotations

-   Get-DpaAnnotation - Complete
-   Add-DpaAnnotation - Test Coverage Needed
-   Remove-DpaAnnotation - Complete
