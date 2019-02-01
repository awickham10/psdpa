function Invoke-DpaRequest {
    [CmdletBinding()]
    param (
        [Parameter()]
        $AccessToken,

        [Parameter(Mandatory)]
        $Endpoint,

        [Parameter()]
        $Request,

        [Parameter()]
        $Method = 'POST'
    )

    if (-not $PSBoundParameters.ContainsKey('AccessToken')) {
        $AccessToken = Get-DpaAccessToken
    }

    if (-not $AccessToken.TokenType -or -not $AccessToken.AccessToken) {
        Stop-Function -Message "You do not have a valid access token"
        return
    }

    $headers = @{
        'Accept' = 'application/json'
        'Content-Type' = 'application/json;charset=UTF-8'
        'Authorization' = "$($AccessToken.TokenType) $($AccessToken.AccessToken)"
    }

    $uri = (Get-DpaConfig -Name 'BaseUri').Value
    if (-not $uri.EndsWith('/') -and -not $Endpoint.StartsWith('/')) {
        $uri += '/'
    }
    $uri += $Endpoint

    $parameters = @{
        'Uri' = $uri
        'Headers' = $headers
        'Method' = $Method
    }
    if ($PSBoundParameters.ContainsKey('Request')) {
        $parameters['Request'] = $Request
    }

    Invoke-RestMethod @parameters | Select-Object -ExpandProperty data | ConvertTo-CustomPSObject
}