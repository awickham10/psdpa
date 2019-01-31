# PSDPA Solarwinds DPA PowerShell Module (Unofficial)
Open source PowerShell module for the Solarwinds DPA REST API. The goal of this
project is to provide complete PowerShell coverage for the Solarwinds DPA REST API.

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