function HandleKiaRequest {
    [CmdletBinding()]
    [OutputType([KiaResponse])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [hashtable]
        $RequestParameters,

        # Specifies that the raw HTTP response should be returned without casting it to [KiaResponse]
        [Parameter()]
        [switch]
        $Raw
    )

    process {
        if ($RequestParameters.WebSession.Headers) {
            # The WebSession is only needed for tracking cookies. We don't want to reuse certain headers against other API endpoints.
            $RequestParameters.WebSession.Headers.Clear()
        }

        # Several headers are common across all API endpoints so use default values unless a header is already provided by the caller.
        foreach ($defaultHeader in $script:default_http_headers.GetEnumerator()) {
            if ($null -eq $RequestParameters.Headers[$defaultHeader.Key]) {
                $RequestParameters.Headers[$defaultHeader.Key] = $defaultHeader.Value
            }
        }

        foreach ($header in $RequestParameters.Headers.GetEnumerator()) {
            if ([string]::IsNullOrWhiteSpace($header.Key) -or [string]::IsNullOrWhiteSpace($header.Value)) {
                throw "Unexpected null or empty header name/value: '$($header.Key)' = '$($header.Value)'."
            }
        }

        $command = [pscustomobject]@{
            DateTime          = Get-Date
            RequestParameters = $RequestParameters
            Response          = $null
            ErrorRecord       = $null
        }
        $script:web_request_history.Add($command)
        while ($script:web_request_history.Count -gt $script:web_request_history_length) {
            $script:web_request_history.RemoveAt(0)
        }

        try {
            # So far it seems all API endpoints return a common json response format with a Status and a Payload.
            $result = Invoke-RestMethod @RequestParameters
            $command.Response = $result

            $response = $result -as [KiaResponse]
            if ($null -eq $response) {
                throw "Failed to authenticate with https://owners.kia.com as $($Credential.UserName)."
            } elseif ($response.Status.ErrorCode) {
                throw "$($response.Status.ErrorMessage). StatusCode $($response.Status.StatusCode), StatusCode $($response.Status.ErrorType), StatusCode $($response.Status.ErrorCode)"
            }

            $response
        } catch {
            $command.ErrorRecord = $_
            throw $_
        }
    }
}
