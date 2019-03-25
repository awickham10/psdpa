# modified from https://community.spiceworks.com/scripts/show/2327-what-is-my-ip-get-whatismyip
param (
    [Parameter()]
    [switch] $EnableException
)

try {
    $webRequest = Invoke-WebRequest -Uri 'https://www.appveyor.com/docs/build-environment/#ip-addresses' -ErrorAction Stop -UseBasicParsing

    $matches = $webRequest.Content | Select-String -Pattern "\b(?:\d{1,3}\.){3}\d{1,3}\b" -AllMatches
    if ($matches) {
        $matches.Matches.Value
    } else {
        Stop-PSFFunction -Message 'Unable to locate any IPs' -EnableException:$EnableException
    }
} catch {
    Stop-PSFFunction -Message 'Unable to process AppVeyor docs' -ErrorRecord $_ -EnableException:$EnableException
}