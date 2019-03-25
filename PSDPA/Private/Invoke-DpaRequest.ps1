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
        $Method = 'POST',

        [Parameter()]
        $Parameters
    )

    if (-not $PSBoundParameters.ContainsKey('AccessToken')) {
        $AccessToken = Get-DpaAccessToken
    }

    if (-not $AccessToken.IsValid()) {
        Stop-PSFFunction -Message "You do not have a valid access token"
        return
    }

    $headers = @{
        'Accept'        = 'application/json'
        'Content-Type'  = 'application/json;charset=UTF-8'
        'Authorization' = $AccessToken.ToAuthorizationHeader()
    }

    $uri = (Get-DpaConfig -Name 'BaseUri').Value
    if (-not $uri.EndsWith('/') -and -not $Endpoint.StartsWith('/')) {
        $uri += '/'
    }
    $uri += $Endpoint

    if ($PSBoundParameters.ContainsKey('Parameters')) {
        $query = @()
        foreach ($parameter in $Parameters.GetEnumerator()) {
            $query += "$($parameter.Key)=" + [System.Web.HttpUtility]::UrlEncode([string]$parameter.Value)
        }

        $uri += '?' + ($query -join '&')
    }

    $params = @{
        'Uri'     = $uri
        'Headers' = $headers
        'Method'  = $Method
    }
    if ($PSBoundParameters.ContainsKey('Request')) {
        $params['Body'] = $Request | ConvertTo-Json
        Write-Verbose $params['Body']
    }

    Invoke-RestMethod @params
}